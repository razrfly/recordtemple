export function getSearchValue() {
  const liveInput = document.querySelector('input[name="search"]:not([type="hidden"])')
  return liveInput ? liveInput.value.trim() : (new URLSearchParams(window.location.search).get('search') ?? '')
}
