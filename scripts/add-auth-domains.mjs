/**
 * Adds Firebase Hosting domains to Authentication authorized domains.
 * Run: node scripts/add-auth-domains.mjs
 */
import { getAuthDomains, updateAuthDomains } from 'firebase-tools/lib/gcp/auth.js';

const projectId = 'denticare-app';
const extra = [
  'denticare-patient.web.app',
  'denticare-patient.firebaseapp.com',
];

const current = await getAuthDomains(projectId);
console.log('Current authorized domains:', current);

const merged = [...new Set([...(current || []), ...extra])];
const updated = await updateAuthDomains(projectId, merged);
console.log('Updated authorized domains:', updated);
