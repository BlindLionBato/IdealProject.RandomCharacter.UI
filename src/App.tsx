import { sayHello } from "./functions";

export function App() {
    const helloMessage = sayHello("John");

    return <>
        <button id="say-hello" onClick={ () => alert(helloMessage) }>Say Hello</button>
    </>
}