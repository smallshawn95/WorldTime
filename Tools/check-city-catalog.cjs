// Validate the bundled city IDs and time-zone names with Node's ICU database.
// Swift's Foundation time-zone lookup is also covered by XCTest on a Mac.
const fs = require('node:fs');
const path = require('node:path');
const assert = require('node:assert/strict');

const source = fs.readFileSync(path.join(__dirname, '../WorldTime/Models/City.swift'), 'utf8');
const pattern = /City\(id: "([^"]+)", name: "([^"]+)", englishName: "([^"]+)", country: "([^"]+)", timeZoneIdentifier: "([^"]+)", artwork: (?:nil|"[^"]+")\)/g;
const cities = [...source.matchAll(pattern)].map(m => ({ id: m[1], name: m[2], country: m[4], zone: m[5] }));
assert(cities.length >= 150, 'The catalog should contain at least 150 cities');
assert.equal(new Set(cities.map(city => city.id)).size, cities.length, 'City IDs must be unique');
assert.deepEqual(cities.slice(0, 3).map(city => city.id), ['london', 'taipei', 'new-york']);
for (const city of cities) {
  assert.doesNotThrow(() => new Intl.DateTimeFormat('en', { timeZone: city.zone }).format(new Date()),
    `${city.name}: unknown time zone ${city.zone}`);
}
const expected = {
  taichung: 'Asia/Taipei', denpasar: 'Asia/Makassar', reykjavik: 'Atlantic/Reykjavik',
  'st-johns': 'America/St_Johns', phoenix: 'America/Phoenix',
  melbourne: 'Australia/Melbourne', apia: 'Pacific/Apia',
  nairobi: 'Africa/Nairobi', 'port-louis': 'Indian/Mauritius'
};
for (const [id, zone] of Object.entries(expected)) {
  assert.equal(cities.find(city => city.id === id)?.zone, zone, id);
}
console.log(`${cities.length} unique cities and their time-zone identifiers validated with ICU ${process.versions.icu} / tzdb ${process.versions.tz}.`);
