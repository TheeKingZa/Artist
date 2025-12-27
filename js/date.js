// date.js
// ============================================================
// Footer Year Auto-Update
// - Keeps the copyright year current.
// - Safe: does nothing if the #year element is missing.
// ============================================================

(() => {
  const yearElement = document.getElementById("year");
  if (!yearElement) return;

  yearElement.textContent = String(new Date().getFullYear());
})();