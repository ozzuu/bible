const searchInput = document.getElementById("search")

document.getElementById("submit_search").onclick = () => {
  location.href = `/${doc}/${book}/search/${searchInput.value}/1`
}
