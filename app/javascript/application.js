const initializeImageUpload = () => {
  const form = document.querySelector('form[action="/posts"]');

  const modal = document.getElementById("product-modal");
  const modalCancel = document.getElementById("modal-cancel");
  const modalOk = document.getElementById("modal-ok");
  const modalUploadButton = document.getElementById("modal-image-upload");
  const modalPreview = document.getElementById("modal-image-preview");
  const background = document.getElementById("login-background");
  const formContainer = document.getElementById("login-form-container");

  let currentIndex = null;
  let currentSlot = null;

  const widget = cloudinary.createUploadWidget({
    cloudName: 'dqjb4apad',
    uploadPreset: 'ml_default',
    multiple: false
  }, (error, result) => {
    if (!error && result.event === "success") {
      const imageUrl = result.info.secure_url;
      const img = document.createElement("img");
      img.src = imageUrl;
      img.style.width = "100%";
      img.style.height = "100%";
      img.style.objectFit = "cover";
      img.style.borderRadius = "12px";
      img.style.cursor = "pointer";

      if (widget.context === "modal") {
        modalPreview.innerHTML = "";
        modalPreview.appendChild(img);
        modalPreview.dataset.imageUrl = imageUrl;
      }

      if (widget.context === "main" && currentSlot) {
        currentSlot.innerHTML = "";
        currentSlot.appendChild(img);
        currentSlot.dataset.filled = "true";

        const hiddenInput = document.createElement("input");
        hiddenInput.type = "hidden";
        hiddenInput.name = "post[image_urls][]";
        hiddenInput.value = imageUrl;
        form.appendChild(hiddenInput);

        img.addEventListener("click", () => {
          if (confirm("この画像を削除しますか？")) {
            currentSlot.innerHTML = `<span style="pointer-events: none; color: #aaa; font-size: 32px">画像を挿入</span>`;
            currentSlot.dataset.filled = "false";
            currentSlot = null;
          }
        });
      }
    }
  });

  document.querySelectorAll(".product-slot").forEach(slot => {
    slot.addEventListener("click", () => {
      currentIndex = slot.dataset.index;
      modal.dataset.slotIndex = currentIndex;
      widget.context = "modal";
      modal.style.display = "flex";
    });
  });

  modalCancel?.addEventListener("click", () => {
    modal.style.display = "none";
  });

  modalOk?.addEventListener("click", () => {
    const title = document.getElementById("modal-title").value.trim();
    const description = document.getElementById("modal-description").value.trim();
    const url = document.getElementById("modal-url").value.trim();
    const imageUrl = modalPreview?.dataset.imageUrl;
    const index = modal.dataset.slotIndex;

    if (!title && !description && !imageUrl) {
      alert("タイトル・説明・画像は必須です");
      return;
    }

    document.getElementById(`product-title-${index}`).value = title;
    document.getElementById(`product-description-${index}`).value = description;
    document.getElementById(`product-url-${index}`).value = url;
    document.getElementById(`product-image-url-${index}`).value = imageUrl;

    const slot = document.querySelector(`.product-slot[data-index="${index}"]`);
    if (slot) {
      slot.innerHTML = `<img src="${imageUrl}" style="width:100%; height:100%; object-fit:cover; border-radius:12px;">`;
      slot.dataset.filled = "true";
    }

    modal.style.display = "none";
  });

  modalUploadButton?.addEventListener("click", () => {
    widget.context = "modal";
    widget.open();
  });

  document.querySelectorAll(".image-slot").forEach(slot => {
    slot.dataset.filled = "false";

    slot.addEventListener("click", () => {
      if (slot.dataset.filled === "true") {
        const img = slot.querySelector("img");
        if (img && confirm("この画像を削除しますか？")) {
          slot.innerHTML = `<span style="pointer-events: none; color: #aaa; font-size: 32px">画像を挿入</span>`;
          slot.dataset.filled = "false";
          currentSlot = null;
        }
        return;
      }

      currentSlot = slot;
      widget.context = "main";
      widget.open();
    });
  });

  if (background && formContainer) {
    background.addEventListener("click", function () {
      formContainer.classList.add("show");
    });
  }
};

document.addEventListener("DOMContentLoaded", initializeImageUpload);
document.addEventListener("turbo:load", initializeImageUpload);