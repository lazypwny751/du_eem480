library ieee;
use ieee.std_logic_1164.all;

entity hello_world_tb is
end entity;

architecture sim of hello_world_tb is
begin
    process
    begin
        report "Hello World!";
		wait;
    end process;
end architecture;
