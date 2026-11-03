// Independent check of XCTest reference expectations with Node's IANA/ICU data.
// This verifies fixtures only; it does not run the Swift implementation.
const assert = require('node:assert/strict');
const fixtures = [
  ['2026-11-03T10:30:00Z', 'Europe/London', '10:30', '+00:00'],
  ['2026-11-03T10:30:00Z', 'Asia/Taipei', '18:30', '+08:00'],
  ['2026-11-03T10:30:00Z', 'America/New_York', '05:30', '-05:00'],
  ['2026-03-29T00:59:00Z', 'Europe/London', '00:59', '+00:00'],
  ['2026-03-29T01:00:00Z', 'Europe/London', '02:00', '+01:00'],
  ['2026-10-25T00:59:00Z', 'Europe/London', '01:59', '+01:00'],
  ['2026-10-25T01:00:00Z', 'Europe/London', '01:00', '+00:00'],
  ['2026-03-08T06:59:00Z', 'America/New_York', '01:59', '-05:00'],
  ['2026-03-08T07:00:00Z', 'America/New_York', '03:00', '-04:00'],
  ['2026-11-01T05:59:00Z', 'America/New_York', '01:59', '-04:00'],
  ['2026-11-01T06:00:00Z', 'America/New_York', '01:00', '-05:00'],
  ['2026-01-01T12:00:00Z', 'Asia/Taipei', '20:00', '+08:00'],
  ['2026-07-01T12:00:00Z', 'Asia/Taipei', '20:00', '+08:00'],
  ['2026-01-01T00:00:00Z', 'Asia/Kolkata', '05:30', '+05:30'],
  ['2026-01-01T00:00:00Z', 'Asia/Kathmandu', '05:45', '+05:45'],
  ['2026-01-01T00:00:00Z', 'Australia/Adelaide', '10:30', '+10:30'],
  ['2026-01-15T12:00:00Z', 'Australia/Melbourne', '23:00', '+11:00'],
  ['2026-07-15T12:00:00Z', 'Australia/Melbourne', '22:00', '+10:00'],
  ['2026-01-15T12:00:00Z', 'America/St_Johns', '08:30', '-03:30'],
  ['2026-07-15T12:00:00Z', 'America/St_Johns', '09:30', '-02:30'],
];
for (const [stamp, timeZone, clock, offset] of fixtures) {
  const date = new Date(stamp);
  const parts = Object.fromEntries(new Intl.DateTimeFormat('en-GB', {
    timeZone, hourCycle: 'h23', hour: '2-digit', minute: '2-digit', timeZoneName: 'longOffset'
  }).formatToParts(date).map(p => [p.type, p.value]));
  assert.equal(`${parts.hour}:${parts.minute}`, clock, `${stamp} ${timeZone}`);
  assert.equal(parts.timeZoneName === 'GMT' ? '+00:00' : parts.timeZoneName.replace('GMT',''), offset);
}
function localDate(stamp, timeZone) {
  const p = Object.fromEntries(new Intl.DateTimeFormat('en-GB', {
    timeZone, year:'numeric', month:'2-digit', day:'2-digit'
  }).formatToParts(new Date(stamp)).map(p=>[p.type,p.value]));
  return `${p.year}-${p.month}-${p.day}`;
}
assert.equal(localDate('2026-12-31T20:30:00Z', 'Asia/Taipei'), '2027-01-01');
assert.equal(localDate('2026-12-31T20:30:00Z', 'America/New_York'), '2026-12-31');
assert.equal(localDate('2026-01-01T11:30:00Z', 'Pacific/Kiritimati'), '2026-01-02');
assert.equal(localDate('2026-01-01T11:30:00Z', 'Etc/GMT+12'), '2025-12-31');
console.log('24 independent time-zone reference fixtures passed. Swift/XCTest not executed.');
