import { Turbo } from "@hotwired/turbo-rails"
Turbo.session.drive = false


// メディアのプレビュー機能
document.addEventListener("turbo:load", function() {
  const mediaUpload = document.getElementById('mediaUpload');

  if (mediaUpload) {
    mediaUpload.addEventListener('change', function(event) {
      const file = event.target.files[0];
      const previewContainer = document.getElementById('mediaPreview');
      const imagePreview = previewContainer.querySelector('.media-preview__image');
      const videoPreview = previewContainer.querySelector('.media-preview__video');
      const defaultText = previewContainer.querySelector('.media-preview__default-text');

      if (file) {
        const fileType = file.type;
        const reader = new FileReader();

        if (fileType.startsWith('image/')) {
          reader.onload = function() {
            imagePreview.setAttribute("src", reader.result);
            imagePreview.style.display = "block";
            videoPreview.style.display = "none";
            defaultText.style.display = "none";
          };
          reader.readAsDataURL(file);
        } else if (fileType.startsWith('video/')) {
          reader.onload = function() {
            videoPreview.setAttribute("src", reader.result);
            videoPreview.style.display = "block";
            imagePreview.style.display = "none";
            defaultText.style.display = "none";
          };
          reader.readAsDataURL(file);
        } else {
          alert("画像または動画のみアップロードできます");
          event.target.value = ''; // 無効なファイルをリセット
          imagePreview.style.display = "none";
          videoPreview.style.display = "none";
          defaultText.style.display = "block";
        }
      } else {
        imagePreview.style.display = "none";
        videoPreview.style.display = "none";
        defaultText.style.display = "block";
      }
    });
  }

  const imageUpload = document.getElementById('imageUpload');
  if (imageUpload) {
    imageUpload.addEventListener('change', function() {
      const file = this.files[0];
      const imagePreview = document.getElementById('imagePreview');
      const imagePreviewImage = imagePreview.querySelector('.image-preview__image');
      const imagePreviewDefaultText = imagePreview.querySelector('.image-preview__default-text');

      if (file) {
        const reader = new FileReader();

        reader.onload = function() {
          imagePreviewImage.setAttribute("src", reader.result);
          imagePreviewImage.style.display = "block"; // 画像を表示
          if (imagePreviewDefaultText) {
            imagePreviewDefaultText.style.display = "none"; // デフォルトテキストを非表示
          }
        };

        reader.readAsDataURL(file);
      }
    });
  }
});


// コメントを編集・削除するためのボタンの表示
document.addEventListener("click", function (event) {
  // ドロップダウンのトグルボタンかどうかを確認
  if (event.target.classList.contains("dropdown-toggle")) {
    const dropdownMenu = event.target.nextElementSibling;

    // ドロップダウンメニューの表示/非表示を切り替える
    if (dropdownMenu && dropdownMenu.classList.contains("dropdown-menu")) {
      const isMenuVisible = dropdownMenu.style.display === "block";
      dropdownMenu.style.display = isMenuVisible ? "none" : "block";
    }
  } else {
    // 他の場所をクリックした場合、すべてのドロップダウンメニューを非表示にする
    document.querySelectorAll(".dropdown-menu").forEach((menu) => {
      menu.style.display = "none";
    });
  }
});


// 本文中のURLをリンクにする
document.addEventListener("DOMContentLoaded", function () {
  console.log("JavaScript is loaded");
  // クラス名を指定して複数要素を取得
  const contentElements = document.querySelectorAll(".auto-change-url");
  contentElements.forEach((contentElement) => {
    // テキストを取得
    let contentText = contentElement.innerHTML;
    // URLを検出する正規表現
    const urlRegex = /(https?:\/\/[^\s]+)/g;
    // URLをリンクに変換
    const linkedText = contentText.replace(urlRegex, function (url) {
      return `<a href="${url}" target="_blank" rel="noopener">${url}</a>`;
    });
    // 変換後のHTMLを挿入
    contentElement.innerHTML = linkedText;
  });
});
