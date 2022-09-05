const searchInput = document.getElementById("search")

document.getElementById("submit_search").onclick = () => {
  location.href = `/${doc}/search/${searchInput.value}/1`
}
