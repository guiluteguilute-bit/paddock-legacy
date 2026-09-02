import { RaceUI } from "./race/race-ui.js";

const initialState = { version: 2, speed: 68, control: 61, mental: 74, energy: 3, season: 1, xp: 740, reputation: 0, raceHistory: [], objectives: { setup: true, lapTime: false, podium: false } };
let stored = {};
try { stored = JSON.parse(localStorage.getItem("paddockLegacy") || "{}"); } catch { localStorage.removeItem("paddockLegacy"); }
const state = { ...initialState, ...stored, objectives: { ...initialState.objectives, ...(stored.objectives || {}) }, raceHistory: Array.isArray(stored.raceHistory) ? stored.raceHistory : [] };
const $ = (selector) => document.querySelector(selector);
const toast = (message) => { const element = $("#toast"); element.textContent = message; element.classList.add("show"); clearTimeout(window.toastTimer); window.toastTimer = setTimeout(() => element.classList.remove("show"), 1800); };
const save = () => localStorage.setItem("paddockLegacy", JSON.stringify(state));
const render = () => {
  ["speed", "control", "mental"].forEach((stat) => $(`#${stat}`).textContent = state[stat]); $("#season").textContent = String(state.season).padStart(2, "0");
  [["#lapObjective", state.objectives.lapTime], ["#podiumObjective", state.objectives.podium]].forEach(([selector, done]) => { const el = $(selector); el.classList.toggle("done", done); if (done) el.querySelector(":scope > span").textContent = "✓"; });
  $("#objectiveCount").textContent = `${Object.values(state.objectives).filter(Boolean).length} / 3`; $(".race-button small").textContent = `ÉNERGIE ${state.energy} / 5`;
};
document.querySelectorAll("[data-upgrade]").forEach((button) => button.addEventListener("click", () => { const stat = button.dataset.upgrade; if (state[stat] >= 99) return toast("Compétence au maximum"); state[stat] += 1; save(); render(); toast("Compétence améliorée  +1"); }));
const race = new RaceUI({ state, save, onComplete: render });
const openRace = () => state.energy > 0 ? race.open() : toast("Énergie insuffisante");
$("#raceButton").addEventListener("click", openRace);
document.querySelectorAll(".bottom-nav button").forEach((button) => button.addEventListener("click", () => { document.querySelectorAll(".bottom-nav button").forEach((item) => item.classList.remove("active")); button.classList.add("active"); if (button.dataset.tab === "race") openRace(); else if (button.dataset.tab !== "garage") toast(`${button.textContent.trim()} — bientôt disponible`); }));
$("#soundButton").addEventListener("click", (event) => { event.currentTarget.classList.toggle("muted"); event.currentTarget.textContent = event.currentTarget.classList.contains("muted") ? "×" : "♪"; toast(event.currentTarget.classList.contains("muted") ? "Son désactivé" : "Son activé"); });
save(); render();
