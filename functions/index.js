const admin = require('firebase-admin');
const { logger } = require('firebase-functions');
const { onDocumentCreated, onDocumentUpdated } = require('firebase-functions/v2/firestore');

admin.initializeApp();

async function getUserTokens(uid) {
  if (!uid) return [];
  try {
    const snap = await admin.firestore().collection('users').doc(uid).collection('fcmTokens').get();
    // tokens stored as doc id (token)
    return snap.docs.map((d) => d.id).filter(Boolean);
  } catch (e) {
    logger.warn('getUserTokens failed', { uid, error: String(e) });
    return [];
  }
}

async function sendToUser(uid, payload) {
  const tokens = await getUserTokens(uid);
  if (!tokens.length) {
    logger.info('No tokens for user, skip notification', { uid });
    return;
  }

  const res = await admin.messaging().sendEachForMulticast({
    tokens,
    notification: payload.notification,
    data: payload.data,
    android: payload.android,
    apns: payload.apns,
  });

  // Cleanup invalid tokens
  const invalidTokens = [];
  res.responses.forEach((r, idx) => {
    if (!r.success) {
      const code = r.error?.code || '';
      if (code.includes('registration-token-not-registered') || code.includes('invalid-registration-token')) {
        invalidTokens.push(tokens[idx]);
      }
    }
  });

  if (invalidTokens.length) {
    logger.info('Cleaning invalid tokens', { uid, count: invalidTokens.length });
    const batch = admin.firestore().batch();
    invalidTokens.forEach((t) => {
      batch.delete(admin.firestore().collection('users').doc(uid).collection('fcmTokens').doc(t));
    });
    await batch.commit();
  }
}

exports.onBookingCreatedNotifyDriver = onDocumentCreated('bookings/{bookingId}', async (event) => {
  const booking = event.data?.data();
  if (!booking) return;

  const driverId = booking.driverId;
  if (!driverId) {
    logger.info('Booking has no driverId, skip', { bookingId: event.params.bookingId });
    return;
  }

  const passengerName = booking.passengerName || 'Un passager';

  await sendToUser(driverId, {
    notification: {
      title: 'Nouvelle réservation',
      body: `${passengerName} a demandé une réservation`,
    },
    data: {
      type: 'booking_created',
      bookingId: event.params.bookingId,
      rideId: String(booking.rideId || ''),
    },
  });
});

exports.onBookingAcceptedNotifyPassenger = onDocumentUpdated('bookings/{bookingId}', async (event) => {
  const before = event.data?.before?.data();
  const after = event.data?.after?.data();
  if (!before || !after) return;

  const prevStatus = before.status;
  const nextStatus = after.status;

  if (prevStatus === nextStatus) return;
  if (String(nextStatus) !== 'accepted') return;

  const passengerId = after.passengerId;
  if (!passengerId) return;

  await sendToUser(passengerId, {
    notification: {
      title: 'Réservation acceptée',
      body: 'Votre demande a été acceptée',
    },
    data: {
      type: 'booking_accepted',
      bookingId: event.params.bookingId,
      rideId: String(after.rideId || ''),
    },
  });
});

exports.onGroupMessageCreatedNotifyMembers = onDocumentCreated('groups/{groupId}/messages/{messageId}', async (event) => {
  const msg = event.data?.data();
  if (!msg) return;

  const groupId = event.params.groupId;
  const senderId = msg.senderId;

  // Read group members
  const groupSnap = await admin.firestore().collection('groups').doc(groupId).get();
  const group = groupSnap.data();
  const members = Array.isArray(group?.memberIds) ? group.memberIds : [];

  const senderName = msg.senderName || 'Quelqu\'un';
  const text = msg.message || 'Nouveau message';

  const targets = members.filter((uid) => uid && uid !== senderId);
  await Promise.all(
    targets.map((uid) =>
      sendToUser(uid, {
        notification: {
          title: 'Nouveau message',
          body: `${senderName}: ${text}`,
        },
        data: {
          type: 'group_message',
          groupId: String(groupId),
          messageId: String(event.params.messageId),
        },
      })
    )
  );
});

exports.onRideChatMessageCreatedNotifyRecipient = onDocumentCreated('ride_chats/{chatId}/messages/{messageId}', async (event) => {
  const msg = event.data?.data();
  if (!msg) return;

  const chatId = event.params.chatId;
  const senderId = msg.senderId;
  const text = msg.message || 'Nouveau message';
  const senderName = msg.senderName || 'Quelqu\'un';

  // Extract rideId and passengerId from chatId format: "rideId_passengerId"
  const parts = chatId.split('_');
  if (parts.length < 2) return;
  const rideId = parts[0];
  const passengerId = parts[1];

  // Determine recipient: if sender is passenger, notify driver; else notify passenger
  let recipientId;
  if (senderId === passengerId) {
    // Notify driver
    const rideSnap = await admin.firestore().collection('rides').doc(rideId).get();
    const ride = rideSnap.data();
    recipientId = ride?.driverId;
  } else {
    // Notify passenger
    recipientId = passengerId;
  }

  if (!recipientId || recipientId === senderId) return;

  await sendToUser(recipientId, {
    notification: {
      title: 'Message de trajet',
      body: `${senderName}: ${text}`,
    },
    data: {
      type: 'ride_chat_message',
      chatId: String(chatId),
      rideId: String(rideId),
      messageId: String(event.params.messageId),
    },
  });
});

exports.onRideRequestAcceptedNotifyPassenger = onDocumentUpdated('ride_requests/{requestId}', async (event) => {
  const before = event.data?.before?.data();
  const after = event.data?.after?.data();
  if (!before || !after) return;

  const prevStatus = before.status;
  const nextStatus = after.status;

  if (prevStatus === nextStatus) return;
  if (String(nextStatus) !== 'accepted') return;

  const passengerId = after.passengerId;
  if (!passengerId) return;

  // Find accepted proposal
  const proposals = Array.isArray(after.proposals) ? after.proposals : [];
  const accepted = proposals.find(p => p.status === 'accepted');
  const driverName = accepted?.driverName || 'Un conducteur';
  const proposedPrice = accepted?.proposedPrice;

  await sendToUser(passengerId, {
    notification: {
      title: 'Demande acceptée',
      body: `${driverName} a accepté votre demande${proposedPrice ? ` pour ${proposedPrice} TND` : ''}`,
    },
    data: {
      type: 'ride_request_accepted',
      requestId: String(event.params.requestId),
      proposalId: String(accepted?.id || ''),
    },
  });
});
