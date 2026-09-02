import { RACE_CONFIG, STRATEGIES, createRoster } from "./race-data.js";

export class SeededRandom {
  constructor(seed = 2701) { this.seed = seed >>> 0; }
  next() { this.seed = (1664525 * this.seed + 1013904223) >>> 0; return this.seed / 4294967296; }
  signed() { return this.next() * 2 - 1; }
}

const clamp = (value, min, max) => Math.max(min, Math.min(max, value));

export class RaceEngine {
  constructor({ playerStats, seed = Date.now(), config = RACE_CONFIG } = {}) {
    this.config = { ...RACE_CONFIG, ...config };
    this.random = new SeededRandom(seed);
    this.time = 0; this.status = "grid"; this.flag = "GRILLE"; this.finishedCount = 0;
    this.events = []; this.bestLap = null; this.playerStartPosition = 0;
    this.drivers = createRoster(playerStats || { speed: 68, control: 61, mental: 74 }).map((driver) => ({
      ...driver, lap: 0, progress: 0, totalDistance: 0, position: 0, speedNow: 0,
      strategy: "normal", tyres: 100, tyreTemperature: 71, lastLap: null, bestLap: null,
      lapStartedAt: 0, finished: false, finishTime: null, overtakeUntil: 0, defendUntil: 0,
      cooldownUntil: 0, errorUntil: 0, nextErrorCheck: 8 + this.random.next() * 8,
    }));
    this.qualify();
  }

  qualify() {
    this.drivers.forEach((d) => {
      const setup = d.isPlayer ? 0.8 : 0;
      d.qualifyingTime = this.config.baseLapTime - (d.speed - 70) * .055 - (d.control - 70) * .018
        - setup + this.random.signed() * (1.25 - d.consistency / 100);
    });
    this.drivers.sort((a, b) => a.qualifyingTime - b.qualifyingTime);
    this.drivers.forEach((d, index) => {
      d.position = index + 1; d.progress = -(index * .0036); d.totalDistance = d.progress;
    });
    this.playerStartPosition = this.player.position;
    return this.standings;
  }

  start() { if (this.status !== "grid") return; this.status = "racing"; this.flag = "VERT"; this.pushEvent("GO !", "Départ de la Riviera Sprint", "start"); }
  setStrategy(strategy) { if (STRATEGIES[strategy]) { this.player.strategy = strategy; this.pushEvent("STRATÉGIE", strategy.toUpperCase(), "strategy"); } }
  activate(action) {
    const d = this.player;
    if (this.status !== "racing" || this.time < d.cooldownUntil) return false;
    if (action === "overtake") d.overtakeUntil = this.time + 5;
    else if (action === "defend") d.defendUntil = this.time + 5;
    else return false;
    d.cooldownUntil = this.time + 13;
    this.pushEvent(action === "overtake" ? "ATTAQUE" : "DÉFENSE", action === "overtake" ? "Mode dépassement engagé" : "Vous fermez la porte", "battle");
    return true;
  }

  tick(dt) {
    if (this.status !== "racing") return;
    dt = Math.min(dt, .1); this.time += dt;
    for (const d of this.drivers) this.updateDriver(d, dt);
    this.resolveTraffic(dt);
    this.updatePositions();
    if (this.finishedCount === this.drivers.length) { this.status = "finished"; this.flag = "DAMIER"; this.pushEvent("ARRIVÉE", "Classement final confirmé", "finish"); }
  }

  updateDriver(d, dt) {
    if (d.finished) return;
    this.updateAiStrategy(d);
    const strategy = STRATEGIES[d.strategy];
    const grip = this.gripFor(d);
    const skill = .91 + d.speed / 780 + d.control / 2500;
    const variation = 1 + this.random.signed() * (100 - d.consistency) * .000045;
    const battle = (d.overtakeUntil > this.time ? 1.022 : 1) * (d.defendUntil > this.time ? .994 : 1);
    const error = d.errorUntil > this.time ? .68 : 1;
    d.speedNow = skill * strategy.pace * grip * variation * battle * error / this.config.baseLapTime;
    d.progress += d.speedNow * dt; d.totalDistance = d.lap + d.progress;
    const wearRate = .235 * strategy.wear * (1.18 - d.tyreManagement / 200);
    d.tyres = clamp(d.tyres - wearRate * dt, 18, 100);
    d.tyreTemperature = clamp(d.tyreTemperature + strategy.heat * dt - (d.tyreTemperature - 82) * .008 * dt, 55, 112);
    this.maybeError(d);
    if (d.progress >= 1) this.completeLap(d);
  }

  gripFor(d) {
    const wear = d.tyres > 55 ? 1 : 1 - (55 - d.tyres) * .0024;
    const temp = 1 - Math.abs(d.tyreTemperature - 84) * .0015;
    return clamp(wear * temp, .82, 1.025);
  }

  updateAiStrategy(d) {
    if (d.isPlayer) return;
    const phase = (d.lap + Math.max(0, d.progress)) / this.config.laps;
    if (d.profile === "aggressive") d.strategy = d.tyres < 38 ? "normal" : "attack";
    else if (d.profile === "conserver") d.strategy = phase > .72 ? "attack" : "conserve";
    else if (d.profile === "finisher") d.strategy = phase > .68 ? "attack" : "normal";
    else if (d.profile === "starter") d.strategy = phase < .22 ? "attack" : "normal";
    else d.strategy = d.tyres < 45 ? "conserve" : "normal";
  }

  maybeError(d) {
    if (this.time < d.nextErrorCheck || d.finished) return;
    d.nextErrorCheck = this.time + 7 + this.random.next() * 9;
    const risk = (d.aggression / 100) * STRATEGIES[d.strategy].risk * (1 - d.control / 145) * (1 - d.mental / 250);
    if (this.random.next() < risk * .13) {
      d.errorUntil = this.time + 1.1 + this.random.next() * 1.6;
      const labels = ["freinage raté", "blocage de roue", "petite sortie"];
      this.pushEvent(`TOUR ${Math.min(d.lap + 1, this.config.laps)}`, `${d.name} : ${labels[Math.floor(this.random.next() * labels.length)]}`, "warning");
    }
  }

  resolveTraffic(dt) {
    const active = this.drivers.filter((d) => !d.finished).sort((a, b) => b.totalDistance - a.totalDistance);
    for (let i = 1; i < active.length; i++) {
      const ahead = active[i - 1], behind = active[i], gap = ahead.totalDistance - behind.totalDistance;
      if (gap < .010 && gap > 0) {
        const attack = behind.speed + behind.control * .35 + behind.aggression * .12 + (behind.overtakeUntil > this.time ? 10 : 0);
        const defence = ahead.speed + ahead.control * .38 + ahead.mental * .12 + (ahead.defendUntil > this.time ? 11 : 0);
        if (attack > defence + this.random.signed() * 12) behind.progress += .0028 * dt;
        else behind.progress -= .0012 * dt;
      }
    }
  }

  completeLap(d) {
    d.progress -= 1; d.lap += 1;
    const lapTime = this.time - d.lapStartedAt; d.lapStartedAt = this.time; d.lastLap = lapTime;
    if (d.lap > 1 && (!d.bestLap || lapTime < d.bestLap)) d.bestLap = lapTime;
    if (d.lap > 1 && (!this.bestLap || lapTime < this.bestLap.time)) {
      this.bestLap = { driverId: d.id, name: d.name, time: lapTime };
      this.pushEvent("⚡ MEILLEUR TOUR", `${d.name} — ${formatTime(lapTime)}`, "best");
    }
    if (d.isPlayer && d.lap === this.config.laps - 1) this.pushEvent("DERNIER TOUR", "Tout se joue maintenant", "last-lap");
    if (d.lap >= this.config.laps) {
      d.finished = true; d.finishTime = this.time; d.totalDistance = this.config.laps; this.finishedCount += 1;
      if (this.finishedCount === 1) { this.flag = "DAMIER"; this.pushEvent("DRAPEAU À DAMIER", `${d.name} remporte la course`, "finish"); }
    }
  }

  updatePositions() {
    const old = new Map(this.drivers.map((d) => [d.id, d.position]));
    this.drivers.sort((a, b) => (b.totalDistance - a.totalDistance) || ((a.finishTime || Infinity) - (b.finishTime || Infinity)));
    this.drivers.forEach((d, i) => d.position = i + 1);
    const previous = old.get("player");
    if (previous && previous !== this.player.position) this.pushEvent(this.player.position < previous ? `▲ P${this.player.position}` : `▼ P${this.player.position}`, this.player.position < previous ? "Vous gagnez une position" : "Vous perdez une position", "position");
  }

  pushEvent(title, message, type) { this.events.unshift({ id: `${this.time}-${this.random.next()}`, time: this.time, title, message, type }); this.events.length = Math.min(this.events.length, 30); }
  get player() { return this.drivers.find((d) => d.isPlayer); }
  get standings() { return [...this.drivers].sort((a, b) => a.position - b.position); }
  get result() { return { start: this.playerStartPosition, finish: this.player.position, bestLap: this.player.bestLap, winner: this.standings[0], completed: this.status === "finished" }; }
}

export function formatTime(seconds) {
  if (!Number.isFinite(seconds)) return "--.---";
  const minutes = Math.floor(seconds / 60), rest = (seconds % 60).toFixed(3).padStart(6, "0");
  return minutes ? `${minutes}:${rest}` : rest;
}
