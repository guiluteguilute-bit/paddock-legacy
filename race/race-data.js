export const RACE_CONFIG = {
  id: "riviera-sprint",
  name: "Riviera Sprint",
  laps: 8,
  lapLengthKm: 1.2,
  baseLapTime: 48.4,
  weather: "sec",
  vehiclePerformance: 70,
};

export const AI_DRIVERS = [
  ["lucas-martin", "L. MARTIN", 7, "Apex Nova", 78, 72, 70, 78, 68, 61, "aggressive", "#ff5a52"],
  ["sofia-rossi", "S. ROSSI", 12, "Kinetic Arc", 75, 80, 77, 65, 84, 77, "balanced", "#58a9ff"],
  ["hugo-dubois", "H. DUBOIS", 44, "Vector Peak", 72, 75, 73, 59, 87, 84, "conserver", "#f4b942"],
  ["maya-smith", "M. SMITH", 18, "Northstar", 77, 68, 69, 84, 62, 58, "aggressive", "#da6cff"],
  ["enzo-bernard", "E. BERNARD", 5, "Ember Fox", 70, 82, 80, 56, 91, 79, "finisher", "#ff843d"],
  ["lina-weber", "L. WEBER", 31, "Silver Finch", 74, 77, 76, 70, 78, 72, "balanced", "#d5e1e8"],
  ["theo-garcia", "T. GARCIA", 21, "Pulse", 73, 70, 68, 80, 69, 64, "starter", "#37dac0"],
  ["ines-leroy", "I. LEROY", 88, "Lumen", 69, 83, 84, 52, 94, 87, "conserver", "#fa7ca8"],
  ["liam-wilson", "L. WILSON", 16, "Helix", 76, 66, 71, 86, 60, 60, "aggressive", "#9676ff"],
  ["emma-sato", "E. SATO", 9, "Meridian", 71, 79, 82, 63, 88, 82, "finisher", "#57c6ff"],
  ["nils-petit", "N. PETIT", 63, "Vertex", 68, 74, 72, 67, 80, 75, "balanced", "#b7d247"],
];

export const STRATEGIES = {
  conserve: { pace: 0.975, wear: 0.57, heat: -0.8, risk: 0.55 },
  normal: { pace: 1, wear: 1, heat: 0.1, risk: 1 },
  attack: { pace: 1.027, wear: 1.68, heat: 1.05, risk: 1.75 },
};

export function createRoster(playerStats) {
  const player = ["player", "N. MOREL", 27, "Paddock Legacy", playerStats.speed, playerStats.control,
    playerStats.mental, 70, 76, 71, "player", "#d9ff43"];
  return [player, ...AI_DRIVERS].map(([id, name, number, team, speed, control, mental, aggression,
    consistency, tyreManagement, profile, color]) => ({ id, name, number, team, speed, control, mental,
    aggression, consistency, tyreManagement, profile, color, isPlayer: id === "player" }));
}
