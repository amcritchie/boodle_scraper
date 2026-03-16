import { Controller } from "@hotwired/stimulus"

const SESSION_KEY = "meme_upload_pending"

export default class extends Controller {
  static targets = ["preview", "pathField", "fileInput", "dropZone", "placeholder", "imageData"]
  static values  = { newUrl: String }

  connect() {
    if (this.hasPreviewTarget) {
      this._restoreDroppedFile()
    }
  }

  // ── Index drop zone ──────────────────────────────────────────────

  dragOver(event) {
    event.preventDefault()
    event.dataTransfer.dropEffect = "copy"
    if (this.hasDropZoneTarget) {
      this.dropZoneTarget.classList.add("ring-2", "ring-purple-400", "bg-purple-900/20")
    }
  }

  dragLeave(event) {
    if (this.hasDropZoneTarget) {
      this.dropZoneTarget.classList.remove("ring-2", "ring-purple-400", "bg-purple-900/20")
    }
  }

  indexDrop(event) {
    event.preventDefault()
    if (this.hasDropZoneTarget) {
      this.dropZoneTarget.classList.remove("ring-2", "ring-purple-400", "bg-purple-900/20")
    }

    const file = event.dataTransfer.files[0]

    if (file) {
      // File drop (from disk or file manager)
      if (!file.type.match(/^image\/(jpeg|jpg|png|gif|webp)$/i) && !file.name.match(/\.(jpg|jpeg|png|gif|webp)$/i)) {
        alert("Please drop an image file (jpg, png, gif, webp)")
        return
      }
      const reader = new FileReader()
      reader.onload = (e) => {
        sessionStorage.setItem(SESSION_KEY, JSON.stringify({
          dataUrl: e.target.result,
          name: file.name,
          type: file.type
        }))
        window.location.href = this.newUrlValue
      }
      reader.readAsDataURL(file)
      return
    }

    // URL drop (dragging an image from a browser tab)
    let url = event.dataTransfer.getData("text/uri-list") ||
              event.dataTransfer.getData("text/plain") || ""
    url = url.split("\n")[0].trim()

    if (url && url.match(/^https?:\/\/.+\.(jpg|jpeg|png|gif|webp)(\?.*)?$/i)) {
      sessionStorage.setItem(SESSION_KEY, JSON.stringify({
        dataUrl: url,
        name: url.split("/").pop().split("?")[0],
        type: "url"
      }))
      window.location.href = this.newUrlValue
      return
    }

    // Try any http URL as a fallback (img src)
    if (url && url.match(/^https?:\/\//i)) {
      sessionStorage.setItem(SESSION_KEY, JSON.stringify({
        dataUrl: url,
        name: url.split("/").pop().split("?")[0] || "image",
        type: "url"
      }))
      window.location.href = this.newUrlValue
      return
    }

    alert("Please drop an image file or image URL")
  }

  // ── Form preview ─────────────────────────────────────────────────

  _restoreDroppedFile() {
    const raw = sessionStorage.getItem(SESSION_KEY)
    if (!raw) return
    try {
      const { dataUrl, name, type } = JSON.parse(raw)
      sessionStorage.removeItem(SESSION_KEY)
      this._showPreview(dataUrl)

      if (type === "url") {
        // URL drop — set the path field directly
        if (this.hasPathFieldTarget) this.pathFieldTarget.value = dataUrl
      } else {
        // File drop — use base64 upload path
        this._setImageData(dataUrl)
        if (this.hasPathFieldTarget) {
          this.pathFieldTarget.placeholder = `File: ${name} (will upload on save)`
        }
      }
    } catch (e) {
      sessionStorage.removeItem(SESSION_KEY)
    }
  }

  fileChange(event) {
    const file = event.target.files[0]
    if (!file) return
    const reader = new FileReader()
    reader.onload = (e) => {
      this._showPreview(e.target.result)
      this._setImageData(e.target.result)
    }
    reader.readAsDataURL(file)
  }

  urlInput(event) {
    clearTimeout(this._urlTimer)
    this._urlTimer = setTimeout(() => {
      const url = event.target.value.trim()
      if (url) {
        this._showPreview(url)
      } else {
        this._clearPreview()
      }
    }, 300)
  }

  _showPreview(src) {
    if (!this.hasPreviewTarget) return
    this.previewTarget.src = src
    this.previewTarget.classList.remove("hidden")
    if (this.hasPlaceholderTarget) this.placeholderTarget.classList.add("hidden")
  }

  _clearPreview() {
    if (!this.hasPreviewTarget) return
    this.previewTarget.src = ""
    this.previewTarget.classList.add("hidden")
    if (this.hasPlaceholderTarget) this.placeholderTarget.classList.remove("hidden")
  }

  _setImageData(dataUrl) {
    if (this.hasImageDataTarget) {
      this.imageDataTarget.value = dataUrl
    }
  }
}
