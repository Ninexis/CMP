"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const cors_1 = __importDefault(require("cors"));
const child_process_1 = require("child_process");
const path_1 = __importDefault(require("path"));
const app = (0, express_1.default)();
const port = 4000;
app.use((0, cors_1.default)());
app.get("/run-terraform", (_, res) => {
    const scriptPath = path_1.default.resolve(__dirname, "../vm-deploy-scripts");
    (0, child_process_1.exec)("./deploy.sh", { cwd: scriptPath, shell: "/bin/sh" }, (error, stdout, stderr) => {
        if (error) {
            console.error(`Erreur de déploiement: ${error.message}`);
            return res.status(500).send(`Terraform Error: ${error.message}`);
        }
        if (stderr)
            console.warn(`Terraform stderr: ${stderr}`);
        console.log(`Terraform stdout: ${stdout}`);
        res.send("Terraform script executed!");
    });
});
app.get("/env", (_, res) => {
    res.json({
        shell: process.env.SHELL,
        path: process.env.PATH,
    });
});
app.listen(port, () => {
    console.log(`🚀 Server running at http://localhost:${port}`);
});
