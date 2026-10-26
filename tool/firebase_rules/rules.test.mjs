import {after, before, test} from 'node:test';
import {readFileSync} from 'node:fs';
import {initializeTestEnvironment, assertFails, assertSucceeds} from '@firebase/rules-unit-testing';
import {doc, setDoc, getDoc, updateDoc, serverTimestamp} from 'firebase/firestore';
import {ref as storageRef, uploadBytes, getBytes, deleteObject} from 'firebase/storage';
import {ref, set, get, serverTimestamp as dbTimestamp} from 'firebase/database';

let env;
const rules = name => readFileSync(new URL(`../../${name}`, import.meta.url), 'utf8');
before(async () => {
  env = await initializeTestEnvironment({
    projectId: 'demo-raysto-rules',
    firestore: {host:'127.0.0.1',port:8185,rules:rules('firestore.rules')},
    database: {host:'127.0.0.1',port:9185,rules:rules('database.rules.json')},
    storage: {host:'127.0.0.1',port:9285,rules:rules('storage.rules')}
  });
});
after(async () => { if (env) await env.cleanup(); });
const user = uid => env.authenticatedContext(uid, {email_verified:true});
const prefs = () => ({displayName:'Raysto user',locale:'ar',updatedAt:serverTimestamp()});

test('Firestore: verified owner can create, read and update valid preferences', async () => {
  const target = doc(user('alice').firestore(), 'users/alice');
  await assertSucceeds(setDoc(target, prefs()));
  await assertSucceeds(getDoc(target));
  await assertSucceeds(updateDoc(target, {locale:'fr',updatedAt:serverTimestamp()}));
});
test('Firestore: another user, guest and unverified account cannot access private preferences', async () => {
  for (const context of [user('bob'),env.unauthenticatedContext(),env.authenticatedContext('alice',{email_verified:false})]) {
    const target = doc(context.firestore(),'users/alice');
    await assertFails(getDoc(target));
    await assertFails(setDoc(target,prefs()));
  }
});
test('Firestore: owner cannot inject roles, remove required fields or corrupt schema', async () => {
  const target = doc(user('alice').firestore(),'users/alice');
  await assertFails(setDoc(target,{...prefs(),role:'owner'}));
  await assertFails(setDoc(target,{locale:'ar',updatedAt:serverTimestamp()}));
  await assertFails(setDoc(target,{...prefs(),displayName:'x'.repeat(81)}));
  await assertFails(updateDoc(target,{locale:'xx',updatedAt:serverTimestamp()}));
  await assertFails(setDoc(target,{...prefs(),updatedAt:new Date(0)}));
  await assertFails(setDoc(doc(user('alice').firestore(),'restaurants/forged'),{owner:'alice'}));
});
test('Storage: owner can upload/read/delete a private valid avatar', async () => {
  const target = storageRef(user('alice').storage(),'users/alice/avatar');
  await assertSucceeds(uploadBytes(target,new Uint8Array([137,80,78,71]),{contentType:'image/png'}));
  await assertSucceeds(getBytes(target));
  await assertSucceeds(deleteObject(target));
});
test('Storage: wrong identity, unverified user and unapproved paths are rejected', async () => {
  await assertSucceeds(uploadBytes(storageRef(user('alice').storage(),'users/alice/avatar'),new Uint8Array([137,80,78,71]),{contentType:'image/png'}));
  for (const context of [user('bob'),env.unauthenticatedContext(),env.authenticatedContext('alice',{email_verified:false})]) {
    const target = storageRef(context.storage(),'users/alice/avatar');
    await assertFails(uploadBytes(target,new Uint8Array([1]),{contentType:'image/png'}));
    await assertFails(getBytes(target));
    await assertFails(deleteObject(target));
  }
  await assertFails(uploadBytes(storageRef(user('alice').storage(),'restaurants/forged/photo'),new Uint8Array([1]),{contentType:'image/png'}));
});
test('Storage: invalid MIME type, empty file and oversized image are rejected', async () => {
  const target = storageRef(user('alice').storage(),'users/alice/avatar');
  await assertFails(uploadBytes(target,new Uint8Array([1]),{contentType:'application/pdf'}));
  await assertFails(uploadBytes(target,new Uint8Array(),{contentType:'image/png'}));
  await assertFails(uploadBytes(target,new Uint8Array(5*1024*1024+1),{contentType:'image/png'}));
});
test('Realtime: owner can write and read a bounded connection state', async () => {
  const target = ref(user('alice').database(),'presence/alice/connection-1');
  await assertSucceeds(set(target,{state:'online',updatedAt:dbTimestamp()}));
  await assertSucceeds(get(target));
  await assertSucceeds(set(target,null));
});
test('Realtime: cross-account, guest and unverified access are rejected', async () => {
  for (const context of [user('bob'),env.unauthenticatedContext(),env.authenticatedContext('alice',{email_verified:false})]) {
    const target = ref(context.database(),'presence/alice/connection-1');
    await assertFails(set(target,{state:'online',updatedAt:dbTimestamp()}));
    await assertFails(get(target));
  }
});
test('Realtime: extra fields, bad timestamps, invalid states and commerce writes are rejected', async () => {
  const database = user('alice').database();
  const target = ref(database,'presence/alice/connection-1');
  await assertFails(set(target,{state:'online',updatedAt:dbTimestamp(),role:'owner'}));
  await assertFails(set(target,{state:'online',updatedAt:0}));
  await assertFails(set(target,{state:'admin',updatedAt:dbTimestamp()}));
  await assertFails(set(ref(database,'orders/forged'),{paid:true}));
  await assertFails(set(ref(database,'presence/alice/'+'x'.repeat(65)),{state:'online',updatedAt:dbTimestamp()}));
});
