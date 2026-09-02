const initialState = { speed: 68, control: 61, mental: 74, energy: 3, season: 1 };
const state = { ...initialState, ...JSON.parse(localStorage.getItem("paddockLegacy") || "{}") };
const $ = (selector) => document.querySelector(selector);
const toast = (message) => {
  const element = $("#toast");
  element.textContent = message;
  element.classList.add("show");
  clearTimeout(window.toastTimer);
  window.toastTimer = setTimeout(() => element.classList.remove("show"), 1800);
};
const save = () => localStorage.setItem("paddockLegacy", JSON.stringify(state));
const render = () => {
  ["speed", "control", "mental"].forEach((stat) => $(`#${stat}`).textContent = state[stat]);
  $("#season").textContent = String(state.season).padStart(2, "0");
};

document.querySelectorAll("[data-upgrade]").forEach((button) => button.addEventListener("click", () => {
  const stat = button.dataset.upgrade;
  if (state[stat] >= 99) return toast("Compétence au maximum");
  state[stat] += 1;
  save(); render(); toast("Compétence améliorée  +1");
}));

const modal = $("#raceModal");
$("#raceButton").addEventListener("click", () => modal.showModal());
$(".modal-close").addEventListener("click", () => modal.close());
$("#startRace").addEventListener("click", () => {
  if ($("#startRace").dataset.finished === "true") {
    modal.close();
    return;
  }
  const lights = $(".lights");
  lights.classList.add("go");
  $("#startRace").disabled = true;
  $("#resultTitle").textContent = "3 · 2 · 1";
  setTimeout(() => {
    const score = Math.round((state.speed + state.control + state.mental) / 3 + Math.random() * 20);
    $("#resultTitle").textContent = score > 78 ? "PODIUM !" : "P6 — SOLIDE";
    $("#resultText").textContent = score > 78 ? "Une course magistrale. +500 XP remportés." : "De précieux points pour la suite du championnat.";
    $("#startRace").textContent = "CONTINUER";
    $("#startRace").disabled = false;
    $("#startRace").dataset.finished = "true";
    lights.classList.remove("go");
  }, 1400);
});

document.querySelectorAll(".bottom-nav button").forEach((button) => button.addEventListener("click", () => {
  document.querySelectorAll(".bottom-nav button").forEach((item) => item.classList.remove("active"));
  button.classList.add("active");
  if (button.dataset.tab === "race") modal.showModal();
  else if (button.dataset.tab !== "garage") toast(`${button.textContent.trim()} — bientôt disponible`);
}));

$("#soundButton").addEventListener("click", (event) => {
  event.currentTarget.classList.toggle("muted");
  event.currentTarget.textContent = event.currentTarget.classList.contains("muted") ? "×" : "♪";
  toast(event.currentTarget.classList.contains("muted") ? "Son désactivé" : "Son activé");
});

render();
