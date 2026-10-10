// Security tests for firestore.rules, run against the local Firestore emulator:
//   firebase emulators:start --only firestore   (port 8180, see firebase.json)
//   cd test_rules && npm test
//
// The aim is to behave like a malicious client: read other people's data,
// write junk, bend the field rules, or touch paths the app never uses.

import { test, before, after, beforeEach } from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import {
  initializeTestEnvironment,
  assertFails,
  assertSucceeds,
} from '@firebase/rules-unit-testing';
import {
  doc, setDoc, getDoc, getDocs, addDoc, updateDoc, deleteDoc,
  collection, query, orderBy, serverTimestamp, Timestamp,
} from 'firebase/firestore';

let env;

before(async () => {
  env = await initializeTestEnvironment({
    projectId: 'friendshipmania-rules-test',
    firestore: {
      host: '127.0.0.1',
      port: 8180,
      rules: fs.readFileSync(new URL('../firestore.rules', import.meta.url), 'utf8'),
    },
  });
});

after(async () => { await env.cleanup(); });
beforeEach(async () => { await env.clearFirestore(); });

const alice = () => env.authenticatedContext('alice').firestore();
const bob = () => env.authenticatedContext('bob').firestore();
const anon = () => env.unauthenticatedContext().firestore();

const validReport = () => ({
  yourName: 'Alice',
  friendName: 'Sam',
  percent: 72,
  bandTitle: 'Actual Real Friends, No Cap',
  bandEmoji: '🔥',
  tagPercents: { roast: 67, loyalty: 100 },
  createdAt: serverTimestamp(),
});

const reports = (db, uid) => collection(db, 'users', uid, 'reports');

// ---------------------------------------------------------------- profile

test('a signed-in user can create and read their own profile', async () => {
  const db = alice();
  await assertSucceeds(setDoc(doc(db, 'users/alice'), {
    displayName: 'Alice', email: 'alice@example.com', updatedAt: serverTimestamp(),
  }));
  await assertSucceeds(getDoc(doc(db, 'users/alice')));
});

test('profile merges (what the app does) are allowed', async () => {
  const db = alice();
  await assertSucceeds(setDoc(doc(db, 'users/alice'),
    { displayName: 'A', email: 'a@x.com', updatedAt: serverTimestamp() }, { merge: true }));
  await assertSucceeds(setDoc(doc(db, 'users/alice'),
    { displayName: 'Alice', email: 'a@x.com', updatedAt: serverTimestamp() }, { merge: true }));
});

test('nobody can read or write while signed out', async () => {
  await env.withSecurityRulesDisabled(async (ctx) => {
    await setDoc(doc(ctx.firestore(), 'users/alice'), { displayName: 'A', email: 'a@x.com' });
  });
  await assertFails(getDoc(doc(anon(), 'users/alice')));
  await assertFails(setDoc(doc(anon(), 'users/alice'), { displayName: 'x', email: 'x' }));
  await assertFails(addDoc(reports(anon(), 'alice'), validReport()));
});

test("a user cannot read, write or delete someone else's profile", async () => {
  await env.withSecurityRulesDisabled(async (ctx) => {
    await setDoc(doc(ctx.firestore(), 'users/alice'), { displayName: 'A', email: 'a@x.com' });
  });
  await assertFails(getDoc(doc(bob(), 'users/alice')));
  await assertFails(setDoc(doc(bob(), 'users/alice'), { displayName: 'hax', email: 'h@x.com' }));
  await assertFails(deleteDoc(doc(bob(), 'users/alice')));
});

test('profile rejects unknown fields (no smuggling extra data)', async () => {
  await assertFails(setDoc(doc(alice(), 'users/alice'), {
    displayName: 'A', email: 'a@x.com', isAdmin: true,
  }));
});

test('profile enforces types and size limits', async () => {
  const db = alice();
  await assertFails(setDoc(doc(db, 'users/alice'), { displayName: 42, email: 'a@x.com' }));
  await assertFails(setDoc(doc(db, 'users/alice'), { displayName: 'x'.repeat(101), email: 'a@x.com' }));
  await assertFails(setDoc(doc(db, 'users/alice'), { displayName: 'A', email: 'e'.repeat(321) }));
});

// ---------------------------------------------------------------- reports

test('a user can create a valid report and read it back', async () => {
  const db = alice();
  const ref = await assertSucceeds(addDoc(reports(db, 'alice'), validReport()));
  const snap = await assertSucceeds(getDoc(ref));
  assert.equal(snap.data().percent, 72);
});

test('a user can list their own reports ordered by date (what My verdicts does)', async () => {
  const db = alice();
  await addDoc(reports(db, 'alice'), validReport());
  await addDoc(reports(db, 'alice'), validReport());
  const snap = await assertSucceeds(getDocs(query(reports(db, 'alice'), orderBy('createdAt', 'desc'))));
  assert.equal(snap.size, 2);
});

test("a user cannot create reports in someone else's account", async () => {
  await assertFails(addDoc(reports(bob(), 'alice'), validReport()));
});

test("a user cannot read or list someone else's reports", async () => {
  let ref;
  await env.withSecurityRulesDisabled(async (ctx) => {
    ref = await addDoc(reports(ctx.firestore(), 'alice'), { ...validReport(), createdAt: Timestamp.now() });
  });
  await assertFails(getDoc(doc(bob(), 'users/alice/reports', ref.id)));
  await assertFails(getDocs(reports(bob(), 'alice')));
});

test("a user cannot delete someone else's report, but can delete their own", async () => {
  const ref = await addDoc(reports(alice(), 'alice'), validReport());
  await assertFails(deleteDoc(doc(bob(), 'users/alice/reports', ref.id)));
  await assertSucceeds(deleteDoc(doc(alice(), 'users/alice/reports', ref.id)));
});

test('reports can never be edited after creation (verdicts are final)', async () => {
  const ref = await addDoc(reports(alice(), 'alice'), validReport());
  await assertFails(updateDoc(doc(alice(), 'users/alice/reports', ref.id), { percent: 100 }));
});

test('report percent must be an integer from 0 to 100', async () => {
  const db = alice();
  for (const bad of [101, -1, 50.5, '72', null, 1e9]) {
    await assertFails(addDoc(reports(db, 'alice'), { ...validReport(), percent: bad }));
  }
  for (const good of [0, 1, 100]) {
    await assertSucceeds(addDoc(reports(db, 'alice'), { ...validReport(), percent: good }));
  }
});

test('report text fields enforce types and length caps', async () => {
  const db = alice();
  await assertFails(addDoc(reports(db, 'alice'), { ...validReport(), yourName: 'x'.repeat(61) }));
  await assertFails(addDoc(reports(db, 'alice'), { ...validReport(), friendName: 'x'.repeat(61) }));
  await assertFails(addDoc(reports(db, 'alice'), { ...validReport(), bandTitle: 'x'.repeat(81) }));
  await assertFails(addDoc(reports(db, 'alice'), { ...validReport(), bandEmoji: 'x'.repeat(17) }));
  await assertFails(addDoc(reports(db, 'alice'), { ...validReport(), yourName: 123 }));
  await assertSucceeds(addDoc(reports(db, 'alice'), { ...validReport(), yourName: 'x'.repeat(60) }));
});

test('a report with a missing required field is rejected', async () => {
  for (const field of ['yourName', 'friendName', 'percent', 'bandTitle', 'bandEmoji', 'tagPercents', 'createdAt']) {
    const r = validReport();
    delete r[field];
    await assertFails(addDoc(reports(alice(), 'alice'), r));
  }
});

test('a report with extra fields is rejected', async () => {
  await assertFails(addDoc(reports(alice(), 'alice'), { ...validReport(), secretNote: 'hi' }));
});

test('createdAt must be the real server time (no backdating or future-dating)', async () => {
  const db = alice();
  await assertFails(addDoc(reports(db, 'alice'), { ...validReport(), createdAt: Timestamp.fromDate(new Date('2020-01-01')) }));
  await assertFails(addDoc(reports(db, 'alice'), { ...validReport(), createdAt: Timestamp.fromDate(new Date('2099-01-01')) }));
  await assertFails(addDoc(reports(db, 'alice'), { ...validReport(), createdAt: 'now' }));
});

test('tagPercents must be a map', async () => {
  await assertFails(addDoc(reports(alice(), 'alice'), { ...validReport(), tagPercents: 'lots' }));
  await assertFails(addDoc(reports(alice(), 'alice'), { ...validReport(), tagPercents: [1, 2] }));
});

// ---------------------------------------------------------------- everything else is closed

test('paths the app never uses are closed, even to signed-in users', async () => {
  const db = alice();
  await assertFails(setDoc(doc(db, 'admin/config'), { x: 1 }));
  await assertFails(getDoc(doc(db, 'admin/config')));
  await assertFails(setDoc(doc(db, 'users/alice/secrets/key'), { x: 1 }));
  await assertFails(setDoc(doc(db, 'public/anything'), { x: 1 }));
});
