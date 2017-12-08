----------------------------------------------------------------------------------
--                 ________  __       ___  _____        __
--                /_  __/ / / / ___  / _/ / ___/______ / /____
--                 / / / /_/ / / _ \/ _/ / /__/ __/ -_) __/ -_)
--                /_/  \____/  \___/_/   \___/_/  \__/\__/\__/
--
----------------------------------------------------------------------------------
--
-- Author(s):   ansotiropoulos
--
-- Design Name: generic_ram
-- Module Name: tb_ram
--
-- Description: Testbench for generic RAM
--
-- Copyright:   (C) 2016 Microprocessor & Hardware Lab, TUC
--
-- This source file is free software; you can redistribute it and/or modify
-- it under the terms of the GNU Lesser General Public License as published
-- by the Free Software Foundation; either version 2.1 of the License, or
-- (at your option) any later version.
--
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_textio.all;
use std.textio.all;

entity tb_ram is
end tb_ram;

architecture behavior of tb_ram is

component RAM
generic (
    DW          : natural := 32;
    AW          : natural := 7;
    BYPASS      : natural := 1;
    STYLE       : string  := "distributed"
);
PORT(
     CLK        : in  std_logic;
     WE         : in  std_logic;
     WA         : in  std_logic_vector (6 downto 0);
     DIN        : in  std_logic_vector (31 downto 0);
     RA         : in  std_logic_vector (6 downto 0);
     DOUT       : out std_logic_vector (31 downto 0)
);
end component;

procedure printf_slv (dat : in std_logic_vector (31 downto 0); file f: text) is
    variable my_line : line;
begin
    write(my_line, CONV_INTEGER(dat));
    write(my_line, string'(" -   ("));
    write(my_line, now);
    write(my_line, string'(")"));
    writeline(f, my_line);
end procedure printf_slv;

constant CLK_period : time := 10 ns;

signal CLK      : std_logic := '0';
signal WE       : std_logic := '0';
signal WA       : std_logic_vector(6 downto 0) := (others => '0');
signal DIN      : std_logic_vector(31 downto 0) := (others => '0');
signal RA       : std_logic_vector(6 downto 0) := (others => '0');
signal DOUT     : std_logic_vector(31 downto 0);

signal data     : std_logic_vector (31 downto 0) := (others => '0');
signal rd_addr  : std_logic_vector (6 downto 0) := (others => '0');
signal wr_addr  : std_logic_vector (6 downto 0) := (others => '0');

signal vld      : std_logic := '0';
file file_dout  : text open WRITE_MODE is "out/test_d.out";


begin

SRAM: RAM
generic map (
    DW          => 32,
    AW          => 7,
    BYPASS      => 1,
    STYLE       => "distributed"
)
port map (
    CLK         => CLK,
    WE          => WE,
    WA          => WA,
    DIN         => DIN,
    RA          => RA,
    DOUT        => DOUT
);

CLKP :process
begin
    CLK <= '0';
    wait for CLK_period/2;
    CLK <= '1';
    wait for CLK_period/2;
end process;

TRCE: process (DOUT)
begin
    printf_slv(DOUT, file_dout);
end process;


-- Stimulus process
SIMUL: process
begin

wait until rising_edge(CLK);

data    <= x"00000001";
rd_addr <= "0000000";
wr_addr <= "0000000";
WE      <= '0';
WA      <= wr_addr;
DIN     <= data;
RA      <= rd_addr;
wait for 100 ns;

for J in 1 to 100 loop
    for I in 1 to 10 loop
        data    <= data + 1;
        rd_addr <= rd_addr + 0;
        wr_addr <= wr_addr + 1;
        WE      <= '1';
        WA      <= wr_addr;
        DIN     <= data;
        RA      <= rd_addr;
        wait for 10 ns;
    end loop;
    for I in 1 to 6 loop
        data    <= data + 1;
        rd_addr <= rd_addr + 1;
        wr_addr <= wr_addr + 1;
        WE      <= '1';
        WA      <= wr_addr;
        DIN     <= data;
        RA      <= rd_addr;
        wait for 10 ns;
    end loop;
end loop;

wait;
end process;

end;
