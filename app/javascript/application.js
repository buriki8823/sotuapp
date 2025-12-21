import "jquery"
window.$ = window.jQuery = require("jquery")

function showLoading() {
  document.getElementById("loading-overlay").style.display = "flex";
}
function hideLoading() {
  document.getElementById("loading-overlay").style.display = "none";
}


const initializeImageUpload = () => {
  console.log("initializeImageUpload が呼ばれました");
  const modal = document.getElementById("product-modal");
  const modalCancel = document.getElementById("modal-cancel");
  const modalOk = document.getElementById("modal-ok");
  const modalUploadButton = document.getElementById("modal-image-upload");
  const modalPreview = document.getElementById("modal-image-preview");
  const background = document.getElementById("login-background");
  const formContainer = document.getElementById("login-form-container");
  const form = document.querySelector("form");

  let uploadContext = null;
  let uploadContextIndex = null;

  

  const widget = cloudinary.createUploadWidget({
    cloudName: 'dqjb4apad',
    uploadPreset: 'ml_default',
    multiple: false
  }, (error, result) => {
    console.log("Cloudinary callback:", result?.event, error);
    if (error) {
      hideLoading();
      alert("アップロードに失敗しました");
      return;
    }

    if (result.event === "upload-added" || result.event === "upload-start") {
      showLoading();
    }

    if (result.event === "success") {
      hideLoading();
      const imageUrl = result.info.secure_url;

      if (uploadContext === "main" && uploadContextIndex !== null) {
        const slot = document.getElementById(`image-slot-${uploadContextIndex}`);
        const hiddenInput = document.getElementById(`image-url-${uploadContextIndex}`);
        const checkbox = document.querySelector(`.image-select-checkbox[data-index="${uploadContextIndex}"]`);

        if (slot) {
          slot.innerHTML = "";
          const img = document.createElement("img");
          img.src = imageUrl;
          img.style.width = "100%";
          img.style.height = "100%";
          img.style.objectFit = "cover";
          img.style.borderRadius = "12px";
          slot.appendChild(img);
        }
        
        if (hiddenInput) {
          hiddenInput.value = imageUrl;
        }


        if (checkbox) {
          checkbox.dataset.imageUrl = imageUrl;
        }
      }

      if (uploadContext === "modal") {
        modalPreview.innerHTML = "";
        const img = document.createElement("img");
        img.src = imageUrl;
        img.style.width = "100%";
        img.style.height = "100%";
        img.style.objectFit = "cover";
        img.style.borderRadius = "12px";
        modalPreview.appendChild(img);
        modalPreview.dataset.imageUrl = imageUrl;
      }
    }
  });

  document.querySelectorAll(".image-slot-wrapper").forEach(wrapper => {
    const index = wrapper.dataset.index;
    const slot = wrapper.querySelector(".image-slot");

    slot?.addEventListener("click", () => {
      uploadContext = "main";
      uploadContextIndex = index;
      widget.open();
    });
  });

  document.querySelectorAll(".image-confirm-button").forEach(button => {
    button.addEventListener("click", () => {
      console.log("OKボタンが押されました:", button.dataset.index);
      const index = button.dataset.index;
      const wrapper = document.querySelector(`.image-slot-wrapper[data-index="${index}"]`);
      const slot = wrapper?.querySelector(".image-slot");
      const img = slot?.querySelector("img");
      const imageUrl = img?.src || "";
        function ensureHiddenInput(wrapper, id, name, value) {
        let input = document.getElementById(id);
        if (!input) {
          input = document.createElement("input");
          input.type = "hidden";
          input.name = name;
          input.id = id;
          wrapper.appendChild(input);
        }
        input.value = value;
      }

      ensureHiddenInput(wrapper, `image-url-${index}`, "post[image_urls][]", imageUrl);
    });
  });


  // モーダル関連（そのまま残す）
  document.querySelectorAll(".product-slot").forEach(slot => {
    slot.addEventListener("click", () => {
      const index = slot.dataset.index;
      modal.dataset.slotIndex = index;
      uploadContext = "modal";
      modalPreview.innerHTML = "";
      modalPreview.dataset.imageUrl = ""; 
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

    if (!title || !description || !imageUrl) {
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
    uploadContext = "modal";
    showLoading();
    widget.open();
  });

  if (background && formContainer) {
    background.addEventListener("click", function () {
      formContainer.classList.add("show");
    });
  }

    document.getElementById("post-submit-button")?.addEventListener("click", () => {
    document.querySelectorAll('input[type="hidden"][name="post[image_urls][]"]').forEach(input => {
      if (!input.value || input.value.trim() === "") {
        input.remove(); // 空の hidden input を削除
      }
    });
  });
};
document.addEventListener("DOMContentLoaded", initializeImageUpload);
document.addEventListener("turbo:load", initializeImageUpload);
