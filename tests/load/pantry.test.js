import http from 'k6/http';
import { check, sleep } from 'k6';
import { Rate, Trend } from 'k6/metrics';

const errorRate = new Rate('errors');
const addLatency = new Trend('add_latency');
const listLatency = new Trend('list_latency');
const deleteLatency = new Trend('delete_latency');

export const options = {
  stages: [
    { duration: '10s', target: 100 },
    { duration: '20s', target: 100 },
    { duration: '10s', target: 0 },
  ],
  thresholds: {
    http_req_duration: ['p(95)<200'],
    errors: ['rate<0.01'],
    http_reqs: ['rate>50'],
  },
};

const BASE_URL = __ENV.SUPABASE_URL;
const AUTH_TOKEN = __ENV.TEST_AUTH_TOKEN;
const ANON_KEY = __ENV.SUPABASE_ANON_KEY;

const headers = {
  'Authorization': `Bearer ${AUTH_TOKEN}`,
  'Content-Type': 'application/json',
  'apikey': ANON_KEY,
};

const SAMPLE_ITEMS = [
  { name: 'Kurczak', quantity: 500, unit: 'g', category: 'meat' },
  { name: 'Ryż', quantity: 1, unit: 'kg', category: 'grains' },
  { name: 'Pomidory', quantity: 4, unit: 'szt', category: 'vegetables' },
  { name: 'Mleko', quantity: 1, unit: 'l', category: 'dairy' },
  { name: 'Jajka', quantity: 12, unit: 'szt', category: 'dairy' },
];

export default function () {
  const item = SAMPLE_ITEMS[Math.floor(Math.random() * SAMPLE_ITEMS.length)];

  // ADD
  const addRes = http.post(
    `${BASE_URL}/functions/v1/manage-pantry`,
    JSON.stringify({ action: 'add', ...item }),
    { headers },
  );
  addLatency.add(addRes.timings.duration);
  const addOk = check(addRes, {
    'add status 200': (r) => r.status === 200,
    'add success': (r) => {
      try { return JSON.parse(r.body).success === true; } catch { return false; }
    },
  });
  errorRate.add(!addOk);

  sleep(Math.random() * 1.5 + 0.5);

  // LIST
  const listRes = http.post(
    `${BASE_URL}/functions/v1/manage-pantry`,
    JSON.stringify({ action: 'list' }),
    { headers },
  );
  listLatency.add(listRes.timings.duration);
  let addedId = null;
  const listOk = check(listRes, {
    'list status 200': (r) => r.status === 200,
    'list returns array': (r) => {
      try {
        const body = JSON.parse(r.body);
        if (body.success && Array.isArray(body.data)) {
          if (body.data.length > 0) addedId = body.data[body.data.length - 1].id;
          return true;
        }
        return false;
      } catch { return false; }
    },
  });
  errorRate.add(!listOk);

  sleep(Math.random() * 1.5 + 0.5);

  // DELETE (last added item if available)
  if (addedId) {
    const delRes = http.post(
      `${BASE_URL}/functions/v1/manage-pantry`,
      JSON.stringify({ action: 'delete', itemId: addedId }),
      { headers },
    );
    deleteLatency.add(delRes.timings.duration);
    const delOk = check(delRes, {
      'delete status 200': (r) => r.status === 200,
      'delete success': (r) => {
        try { return JSON.parse(r.body).success === true; } catch { return false; }
      },
    });
    errorRate.add(!delOk);

    sleep(Math.random() * 1.5 + 0.5);
  }
}

// Run:
// k6 run \
//   -e SUPABASE_URL=https://<project>.supabase.co \
//   -e TEST_AUTH_TOKEN=<jwt> \
//   -e SUPABASE_ANON_KEY=<anon_key> \
//   tests/load/pantry.test.js
