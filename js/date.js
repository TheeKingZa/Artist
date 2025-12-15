// date.js
// ----------------------------------
// This script automatically updates
// the footer year based on the current date
// ----------------------------------

// Wait until the DOM is fully loaded
document.addEventListener("DOMContentLoaded", () => {
  // Get the current year from the system date
  const currentYear = new Date().getFullYear();

  // Find the span where the year should appear
  const yearElement = document.getElementById("year");

  // Safety check (prevents errors if element is missing)
  if (yearElement) {
    yearElement.textContent = currentYear;
  }
});
