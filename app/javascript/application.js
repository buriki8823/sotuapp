// Entry point for the build script in your package.json
import "@hotwired/turbo-rails"
import "./controllers"
import * as bootstrap from "bootstrap"

document.addEventListener("turbo:load", () => {
  const bg = document.getElementById("login-background");
  const card = document.querySelector(".login-card");

  if (card) {
    card.classList.remove("show"); // 初期状態をリセット
  }

  if (bg && card) {
    bg.addEventListener("click", () => {
      card.classList.add("show");
    });
  }
});