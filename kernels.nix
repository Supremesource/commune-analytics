{...}: {
  kernel.python.myKernel = {
    enable = true;
    displayName = "FUCK NIX + PYTHON KERNEL";
    extraPackages = ps: with ps; [numpy tabulate requests];
  };
}