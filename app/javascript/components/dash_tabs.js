
const selectTabs = () => {
  const btnProf = document.querySelector("#btn-profile");
  const btnKids = document.querySelector("#btn-kids");
  const blockProf = document.querySelector("#dash-tab1");
  const blockKids = document.querySelector("#dash-tab2");

  if(blockProf) {
    btnProf.addEventListener("click", (event) => {
      event.preventDefault();
      event.currentTarget.classList.add("active");
      btnKids.classList.remove("active");
      blockProf.classList.remove("toggle-display");
      blockKids.classList.add("toggle-display");

    });

    btnKids.addEventListener("click", (event) => {
      event.preventDefault();
      event.currentTarget.classList.add("active");
      btnProf.classList.remove("active");
      blockKids.classList.remove("toggle-display")
      blockProf.classList.add("toggle-display");
      ;
    });
  }
}

export {selectTabs};
