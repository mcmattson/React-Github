import React from 'react';
import ReactDOM from 'react-dom';
import App from '../../client/src/components/App.js';

jest.mock("react-dom", () => ({ render: jest.fn() }));

describe("App.js root", () => {
    test("mmattson: render without crashing", () => {
        const div = document.createElement("div");
        div.id = "root";
        document.body.appendChild(div);
        require("../src/entry");
        expect(ReactDOM.render).toHaveBeenCalledWith(<App />, div);
    });
});