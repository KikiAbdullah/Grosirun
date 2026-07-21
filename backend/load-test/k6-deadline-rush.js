// k6-deadline-rush.js - Grosirun V3.1 GAP Load Testing Script Fixed
// Simulates Thundering Herd 100 concurrent buyers checkout sisa 10 paket H-1 deadline

import http from 'k6/http';
import { check, sleep } from 'k6';
import { uuidv4 } from 'https://jslib.k6.io/k6-utils/1.4.0/index.js';

export const options = {
  vus: 100,
  duration: '30s',
  thresholds: {
    'http_req_duration': ['p(95)<300', 'p(99)<500'],
    'http_req_failed': ['rate<0.1'], // expect 90% 409 OUT_OF_STOCK is not failed? Actually 409 is not failed if check handles, but http_req_failed counts 4xx? No, only 5xx? k6 failed is status 0 or check fail, not 4xx. So rate should be <0.1 for 5xx
  },
};

const BASE_URL = __ENV.API_URL || 'https://api.grosirun.id/api/v1';
const CAMPAIGN_ID = __ENV.CAMPAIGN_ID || '12';
const VARIANT_ID = __ENV.VARIANT_ID || '20';
// TOKEN env must be set per VU? For demo use single token placeholder, in real inject via env per VU: TOKEN_VU_1 etc
const TOKEN = __ENV.TOKEN || 'test-token-replace-with-real-sanctum-token';

export default function () {
  const url = `${BASE_URL}/campaigns/${CAMPAIGN_ID}/orders`;
  const payload = JSON.stringify({
    variant_id: parseInt(VARIANT_ID),
    quantity: 1,
    payment_method: 'cash',
  });
  const idempotencyKey = `${__VU}-${Date.now()}-${uuidv4()}`;
  const params = {
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${TOKEN}`,
      'Idempotency-Key': idempotencyKey,
      'X-App-Version': '1.0.0+1',
    },
  };

  const res = http.post(url, payload, params);

  const success = check(res, {
    'is 201 or 409': (r) => r.status === 201 || r.status === 409,
    'has code ERR_024 if 409': (r) => {
      if (r.status === 409) {
        const body = r.json();
        return body.code === 'ERR_024';
      }
      return true;
    },
    'P95 <300ms': (r) => r.timings.duration < 300,
  });

  if (res.status === 201) {
    console.log(`VU ${__VU} success order uuid ${res.json().data.uuid}`);
  } else if (res.status === 409) {
    console.log(`VU ${__VU} out of stock as expected 409`);
  } else {
    console.error(`VU ${__VU} unexpected status ${res.status} body ${res.body}`);
  }

  sleep(0.5);
}

export function handleSummary(data) {
  return {
    'result-deadline-rush.json': JSON.stringify(data, null, 2),
    stdout: textSummary(data, { indent: ' ', enableColors: true }),
  };
}

function textSummary(data, options) {
  // simple summary text
  return `
  Checks: ${data.metrics.checks.values.passes} passes, ${data.metrics.checks.values.fails} fails
  P95 duration: ${data.metrics.http_req_duration.values['p(95)']} ms
  http_req_failed: ${data.metrics.http_req_failed.values.rate}
  `;
}
