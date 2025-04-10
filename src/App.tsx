import { sayHello } from "./functions";

export function App() {
    const helloMessage = sayHello("Anny");

    return <>
        <button id="say-hello" onClick={ () => alert(helloMessage) }>Say Hello</button>
    </>
}