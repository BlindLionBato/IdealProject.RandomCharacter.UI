import { sayHello } from "./functions";

document.getElementById("say-hello")?.addEventListener("click", () => {
    const helloMessage = sayHello("John");
    alert(helloMessage);
});