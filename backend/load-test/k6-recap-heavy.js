// k6-recap-heavy.js - 10 VUs GET recap PDF heavy - tests read replica + P95 <3s

import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  vus: 10,
  duration: '60s',
  thresholds: {
    'http_req_duration': ['p(95)<3000'], // recap PDF heavy allow 3s P95
    'http_req_failed': ['rate<0.05'],
  },
};

const BASE_URL = __ENV.API_URL || 'https://api.grosirun.id/api/v1';
const CAMPAIGN_ID = __ENV.CAMPAIGN_ID || '12';
const TOKEN = __ENV.TOKEN || 'test-token';

export default function () {
  const url = `${BASE_URL}/campaigns/${CAMPAIGN_ID}/recap`;
  const params = {
    headers: {
      'Authorization': `Bearer ${TOKEN}`,
    },
  };

  const res = http.get(url, params);

  check(res, {
    '200': (r) => r.status === 200,
    'has pdf_url': (r) => {
      try {
        const body = r.json();
        return body.data.pdf_url !== undefined;
      } catch { return false; }
    },
  });

  sleep(1);
}
