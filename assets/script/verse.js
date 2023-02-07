const verses = [...document.getElementsByClassName("current-verse")]

window.onhashchange = () =>
  verses.map((verse) => {
    const curr = window.location.hash.substring(1)
    if (curr.length > 0) verse.innerText = ":" + curr
    else verse.innerText = ""
  })
window.onhashchange()

const strongs = document.getElementById("strongs")
strongs.onclick = () =>
  document.body.style.setProperty(
    "--strongs",
    strongs.checked ? "inline" : "none"
  )
strongs.onclick()

const explanations = document.getElementById("explanations")
explanations.onclick = () =>
  document.body.style.setProperty(
    "--explanations",
    explanations.checked ? "inline" : "none"
  )
explanations.onclick()
