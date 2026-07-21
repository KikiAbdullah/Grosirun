// k6-orders-race.js - 2 VUs race same variant 1 quota - tests lockForUpdate zero oversell

import http from 'k6/http';
import { check, sleep } from 'k6';
import { uuidv4 } from 'https://jslib.k6.io/k6-utils/1.4.0/index.js';

export const options = {
  vus: 2,
  iterations: 2,
  thresholds: {
    'http_req_duration': ['p(95)<300'],
  },
};

const BASE_URL = __ENV.API_URL || 'https://api.grosirun.id/api/v1';
const CAMPAIGN_ID = __ENV.CAMPAIGN_ID || '12';
const VARIANT_ID = __ENV.VARIANT_ID || '20';
const TOKEN = __ENV.TOKEN || 'test-token';

export default function () {
  const url = `${BASE_URL}/campaigns/${CAMPAIGN_ID}/orders`;
  const payload = JSON.stringify({
    variant_id: parseInt(VARIANT_ID),
    quantity: 1,
    payment_method: 'cash',
  });
  const params = {
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${TOKEN}`,
      'Idempotency-Key': `${__VU}-${Date.now()}-${uuidv4()}`,
    },
  };

  const res = http.post(url, payload, params);

  check(res, {
    '201 or 409': (r) => r.status === 201 || r.status === 409,
    'no 5xx': (r) => r.status < 500,
  });

  console.log(`VU ${__VU} iter ${__ITER} status ${res.status}`);

  sleep(1);
}
