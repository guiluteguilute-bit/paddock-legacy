import { RaceEngine, formatTime } from "./race-engine.js";

const $ = (selector) => document.querySelector(selector);
const clamp = (v, min, max) => Math.max(min, Math.min(max, v));

export class RaceUI {
  constructor({ state, save, onComplete }) {
    this.state = state; this.save = save; this.onComplete = onComplete; this.engine = null;
    this.playback = 1; this.paused = false; this.lastFrame = 0; this.seenEvent = null; this.finishedShown = false;
    this.path = $("#racingLine"); this.karts = new Map(); this.bind();
  }

  bind() {
    $("#startRace").addEventListener("click", () => this.runLights());
    $("#pauseRace").addEventListener("click", () => { this.paused = !this.paused; $("#pauseRace").textContent = this.paused ? "▶ REPRENDRE" : "Ⅱ PAUSE"; });
    document.querySelectorAll("[data-speed]").forEach((b) => b.addEventListener("click", () => { this.playback = Number(b.dataset.speed); document.querySelectorAll("[data-speed]").forEach(x => x.classList.toggle("active", x === b)); }));
    document.querySelectorAll("[data-strategy]").forEach((b) => b.addEventListener("click", () => { this.engine?.setStrategy(b.dataset.strategy); document.querySelectorAll("[data-strategy]").forEach(x => x.classList.toggle("active", x === b)); }));
    $("#overtakeButton").addEventListener("click", () => this.engine?.activate("overtake"));
    $("#defendButton").addEventListener("click", () => this.engine?.activate("defend"));
    document.querySelectorAll("[data-camera]").forEach((b) => b.addEventListener("click", () => { document.querySelectorAll("[data-camera]").forEach(x => x.classList.toggle("active", x === b)); $("#trackMap").classList.toggle("follow-mode", b.dataset.camera === "follow"); }));
    $("#exitRace").addEventListener("click", () => { if (!this.engine || this.engine.status === "grid" || confirm("Abandonner cette course ?")) this.close(); });
    $("#continueRace").addEventListener("click", () => { $("#resultsModal").close(); this.close(); this.onComplete?.(); });
  }

  open() {
    const seed = ((Date.now() / 1000) | 0) ^ (this.state.raceHistory?.length || 0) * 7919;
    this.engine = new RaceEngine({ playerStats: this.state, seed }); this.finishedShown = false; this.seenEvent = null;
    $("#raceScreen").classList.add("open"); $("#raceScreen").setAttribute("aria-hidden", "false"); document.body.classList.add("racing");
    $("#startSequence").classList.remove("hidden"); $("#startMessage").textContent = "PRÊT ?"; $("#startRace").disabled = false;
    this.createKarts(); this.renderGrid(); this.render(); this.lastFrame = performance.now(); requestAnimationFrame((t) => this.loop(t));
  }

  close() { $("#raceScreen").classList.remove("open"); $("#raceScreen").setAttribute("aria-hidden", "true"); document.body.classList.remove("racing"); this.engine = null; }

  createKarts() {
    const layer = $("#kartLayer"); layer.replaceChildren(); this.karts.clear();
    this.engine.drivers.forEach((d) => {
      const group = document.createElementNS("http://www.w3.org/2000/svg", "g"); group.classList.add("race-kart"); if (d.isPlayer) group.classList.add("player-kart");
      group.innerHTML = `<ellipse cx="0" cy="5" rx="13" ry="7" class="kart-shadow"/><rect x="-11" y="-7" width="22" height="15" rx="5" fill="${d.color}"/><rect x="-14" y="-8" width="5" height="7" rx="2"/><rect x="9" y="-8" width="5" height="7" rx="2"/><rect x="-14" y="3" width="5" height="7" rx="2"/><rect x="9" y="3" width="5" height="7" rx="2"/><circle cy="-3" r="4" fill="#e9edf0"/><text x="0" y="5">${d.number}</text>${d.isPlayer ? '<path d="M0 -25l-7-9h14z" class="player-arrow"/>' : ''}`;
      layer.append(group); this.karts.set(d.id, group);
    });
  }

  renderGrid() {
    $("#standings").innerHTML = this.engine.standings.map((d) => `<div class="standing-row ${d.isPlayer ? "player" : ""}"><b>P${d.position}</b><i style="--team:${d.color}"></i><span>${d.name}</span><small>${formatTime(d.qualifyingTime)}</small></div>`).join("");
  }

  async runLights() {
    const button = $("#startRace"); button.disabled = true; const lights = [...document.querySelectorAll(".start-lights i")];
    for (let i = 0; i < 5; i++) { await new Promise(r => setTimeout(r, 520)); lights[i].classList.add("on"); $("#startMessage").textContent = String(5 - i); }
    await new Promise(r => setTimeout(r, 650)); lights.forEach(l => l.classList.remove("on")); $("#startMessage").textContent = "GO !"; this.engine.start();
    setTimeout(() => $("#startSequence").classList.add("hidden"), 650);
  }

  loop(now) {
    if (!this.engine) return;
    const dt = Math.min((now - this.lastFrame) / 1000, .05); this.lastFrame = now;
    if (!this.paused) for (let i = 0; i < this.playback; i++) this.engine.tick(dt);
    this.render();
    if (this.engine.status === "finished" && !this.finishedShown) { this.finishedShown = true; setTimeout(() => this.showResults(), 1200); }
    requestAnimationFrame((t) => this.loop(t));
  }

  render() {
    const e = this.engine, player = e.player, standings = e.standings;
    $("#currentLap").textContent = Math.min(e.config.laps, player.lap + 1); $("#raceFlag").textContent = e.flag;
    $("#raceClock").textContent = `${Math.floor(e.time / 60)}:${(e.time % 60).toFixed(1).padStart(4, "0")}`;
    standings.forEach((d, index) => this.positionKart(d, index));
    const leader = standings[0], leaderDistance = leader.totalDistance;
    $("#standings").innerHTML = standings.map((d) => {
      const gap = d === leader ? "LEADER" : d.finished ? `+${(d.finishTime - leader.finishTime).toFixed(1)}` : `+${Math.max(0, (leaderDistance - d.totalDistance) * e.config.baseLapTime).toFixed(1)}`;
      return `<div class="standing-row ${d.isPlayer ? "player" : ""}"><b>P${d.position}</b><i style="--team:${d.color}"></i><span>${d.name}</span><small>${gap}</small></div>`;
    }).join("");
    $("#bestLap").textContent = e.bestLap ? formatTime(e.bestLap.time) : "--.---"; $("#bestDriver").textContent = e.bestLap?.name || "—";
    $("#playerPosition").textContent = `P${player.position}`; $("#tyreWear").textContent = `${Math.round(player.tyres)}%`;
    $("#tyreTemp").textContent = player.tyreTemperature < 72 ? "FROID" : player.tyreTemperature < 94 ? "OPTIMAL" : player.tyreTemperature < 104 ? "CHAUD" : "SURCHAUFFE";
    const ahead = standings[player.position - 2]; $("#playerGap").textContent = ahead ? `+${Math.max(0, (ahead.totalDistance - player.totalDistance) * e.config.baseLapTime).toFixed(1)} s` : "LEADER";
    const cooldown = Math.max(0, player.cooldownUntil - e.time); $("#cooldownLabel").textContent = cooldown ? `COOLDOWN ${Math.ceil(cooldown)} s` : "PRÊT";
    $("#overtakeButton").disabled = cooldown > 0; $("#defendButton").disabled = cooldown > 0;
    this.renderEvents();
  }

  positionKart(d, index) {
    const length = this.path.getTotalLength(); let distance = ((d.progress % 1) + 1) % 1;
    const p = this.path.getPointAtLength(distance * length), p2 = this.path.getPointAtLength(((distance + .002) % 1) * length);
    const angle = Math.atan2(p2.y - p.y, p2.x - p.x) * 180 / Math.PI; const lane = ((index % 3) - 1) * 5;
    this.karts.get(d.id)?.setAttribute("transform", `translate(${p.x} ${p.y + lane}) rotate(${angle})`);
  }

  renderEvents() {
    const events = this.engine.events; if (events[0] && events[0].id !== this.seenEvent) {
      this.seenEvent = events[0].id; const notice = $("#raceNotice"); notice.innerHTML = `<strong>${events[0].title}</strong><span>${events[0].message}</span>`; notice.classList.remove("show"); void notice.offsetWidth; notice.classList.add("show");
    }
    $("#eventFeed").innerHTML = events.slice(0, 7).map(ev => `<article class="${ev.type}"><small>${Math.floor(ev.time / 60)}:${String(Math.floor(ev.time % 60)).padStart(2, "0")}</small><div><strong>${ev.title}</strong><span>${ev.message}</span></div></article>`).join("") || "<p>En attente du départ…</p>";
  }

  showResults() {
    const e = this.engine, r = e.result, leader = e.standings[0];
    const xp = 140 + Math.max(0, 13 - r.finish) * 18 + (r.finish <= 3 ? 220 : 0) + (e.bestLap?.driverId === "player" ? 100 : 0);
    const reputation = r.finish === 1 ? 16 : r.finish <= 3 ? 12 : r.finish <= 5 ? 7 : 3;
    const result = { circuit: e.config.name, date: new Date().toISOString(), start: r.start, finish: r.finish, bestLap: r.bestLap, xp, seed: e.random.seed };
    this.state.xp = (this.state.xp || 740) + xp; this.state.reputation = (this.state.reputation || 0) + reputation; this.state.energy = Math.max(0, (this.state.energy ?? 3) - 1);
    this.state.raceHistory = [...(this.state.raceHistory || []), result].slice(-30); this.state.objectives = { setup: true, lapTime: !!r.bestLap && r.bestLap <= 48.21, podium: r.finish <= 3 }; this.save();
    $("#finalStandings").innerHTML = e.standings.map((d) => `<div class="final-row ${d.isPlayer ? "player" : ""}"><b>${d.position}</b><span>${d.name}</span><small>${d === leader ? formatTime(d.finishTime) : `+${(d.finishTime - leader.finishTime).toFixed(1)}`}</small></div>`).join("");
    $("#playerResult").innerHTML = `<div><small>DÉPART</small><strong>P${r.start}</strong></div><div><small>ARRIVÉE</small><strong>P${r.finish}</strong></div><div><small>POSITIONS</small><strong>${r.start - r.finish >= 0 ? "+" : ""}${r.start - r.finish}</strong></div><div><small>MEILLEUR TOUR</small><strong>${formatTime(r.bestLap)}</strong></div><div><small>XP</small><strong>+${xp}</strong></div><div><small>RÉPUTATION</small><strong>+${reputation}</strong></div>`;
    $("#resultsModal").showModal();
  }
}
