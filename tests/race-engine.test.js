import test from "node:test";
import assert from "node:assert/strict";
import { RaceEngine } from "../race/race-engine.js";

const stats = { speed: 72, control: 72, mental: 72 };
function finish(engine, strategy = "normal") {
  engine.setStrategy(strategy); engine.start();
  let ticks = 0;
  while (engine.status !== "finished" && ticks++ < 12000) engine.tick(.1);
  assert.equal(engine.status, "finished");
  return engine;
}

test("qualification creates a complete unique grid", () => {
  const race = new RaceEngine({ playerStats: stats, seed: 42 });
  assert.equal(race.drivers.length, 12);
  assert.deepEqual(race.standings.map(d => d.position), Array.from({ length: 12 }, (_, i) => i + 1));
  assert.equal(new Set(race.drivers.map(d => d.id)).size, 12);
});

test("all competitors complete every lap once and receive a final position", () => {
  const race = finish(new RaceEngine({ playerStats: stats, seed: 43, config: { laps: 3 } }));
  assert.equal(race.finishedCount, 12);
  assert.ok(race.drivers.every(d => d.lap === 3 && d.finished && d.finishTime));
  assert.equal(new Set(race.drivers.map(d => d.position)).size, 12);
  assert.equal(race.events.filter(e => e.title === "ARRIVÉE").length, 1);
});

test("strategy changes pace, tyre wear and temperature", () => {
  const conserve = new RaceEngine({ playerStats: stats, seed: 99, config: { laps: 2 } });
  const attack = new RaceEngine({ playerStats: stats, seed: 99, config: { laps: 2 } });
  conserve.start(); attack.start(); conserve.setStrategy("conserve"); attack.setStrategy("attack");
  for (let i = 0; i < 300; i++) { conserve.tick(.1); attack.tick(.1); }
  assert.ok(attack.player.totalDistance > conserve.player.totalDistance);
  assert.ok(attack.player.tyres < conserve.player.tyres);
  assert.ok(attack.player.tyreTemperature > conserve.player.tyreTemperature);
});

test("overtake and defend actions apply a duration and shared cooldown", () => {
  const race = new RaceEngine({ playerStats: stats, seed: 7 }); race.start();
  assert.equal(race.activate("overtake"), true);
  assert.ok(race.player.overtakeUntil > race.time);
  assert.equal(race.activate("defend"), false);
  for (let i = 0; i < 131; i++) race.tick(.1);
  assert.equal(race.activate("defend"), true);
});

test("a fixed seed reproduces the final classification", () => {
  const a = finish(new RaceEngine({ playerStats: stats, seed: 2701, config: { laps: 3 } }));
  const b = finish(new RaceEngine({ playerStats: stats, seed: 2701, config: { laps: 3 } }));
  assert.deepEqual(a.standings.map(d => d.id), b.standings.map(d => d.id));
  assert.deepEqual(a.standings.map(d => d.finishTime), b.standings.map(d => d.finishTime));
});

test("attack, conserve, balanced and late attack produce valid varied races", () => {
  const scenarios = ["attack", "conserve", "normal", "late"];
  const results = scenarios.map((mode, index) => {
    const race = new RaceEngine({ playerStats: stats, seed: 300 + index, config: { laps: 3 } }); race.start();
    let ticks = 0;
    while (race.status !== "finished" && ticks++ < 12000) { if (mode === "late" && race.player.lap >= 2) race.setStrategy("attack"); else if (mode !== "late") race.player.strategy = mode; race.tick(.1); }
    assert.equal(race.status, "finished"); return `${race.player.position}-${Math.round(race.player.tyres)}`;
  });
  assert.ok(new Set(results).size > 1);
});
