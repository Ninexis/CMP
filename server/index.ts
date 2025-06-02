import express from "express";
import cors from "cors";
import { exec } from "child_process";
import path from "path";

const app = express();
const port = 4000;

app.use(cors());

app.get("/run-terraform", (_, res) => {
  const scriptPath = path.resolve(__dirname, "../vm-deploy-scripts");
  exec("terraform init && terraform apply -auto-approve", { cwd: scriptPath, shell: "/bin/sh" }, (error, stdout, stderr) => {
    if (error) {
      console.error(`Terraform Error: ${error.message}`);
      return res.status(500).send(`Terraform Error: ${error.message}`);
    }
    if (stderr) console.warn(`Terraform stderr: ${stderr}`);
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