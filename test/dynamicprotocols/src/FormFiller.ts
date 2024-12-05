/* 
    This file is used for building the minified version (.min.js file) of the FormFiller component
    Webpack detects any imports used and automatically adds them to the build.
*/
import FormFiller from "./components/formFiller/formFiller";

// This line is used to expose the FormFiller component to be globally accessible through "window."
(window as any).FormFiller = FormFiller;
