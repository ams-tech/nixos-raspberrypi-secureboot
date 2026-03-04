{ lib, testers }:
{
  key-generation = testers.runNixOSTest {
    name = "key-genertion";
  };
}