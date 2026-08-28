import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "all", "item", "submit", "count" ]

  connect() {
    this.refresh()
  }

  toggleAll(event) {
    this.itemTargets.forEach((item) => {
      item.checked = event.target.checked
    })

    this.refresh()
  }

  refresh() {
    const selectedCount = this.itemTargets.filter((item) => item.checked).length
    const totalCount = this.itemTargets.length

    this.submitTarget.disabled = selectedCount === 0
    this.countTarget.textContent = this.selectionLabel(selectedCount)

    if (this.hasAllTarget) {
      this.allTarget.checked = totalCount > 0 && selectedCount === totalCount
      this.allTarget.indeterminate = selectedCount > 0 && selectedCount < totalCount
    }
  }

  selectionLabel(count) {
    if (count === 0) return "Nenhum jornal selecionado"
    if (count === 1) return "1 jornal selecionado"

    return `${count} jornais selecionados`
  }
}
