--libreria
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
-- entidad
entity P4 is
port(clk: in std_logic;
 reset: in std_logic;
pulsador_f: in std_logic;
f: in std_logic;
pulsador: in std_logic;

fin_de_cuenta: out std_logic;
rojo:out std_logic;
ambar: out std_logic;
verde: out std_logic;
enable: in std_logic;
cuenta_s: out std_logic_vector (2 downto 0)

);
end P4;
-- arquitectura
architecture funcional of P4 is
type estado is (inicial, r, a, v);
signal e_sig, e_actual: estado;
signal cuenta: unsigned (2 downto 0);
-- detector de flancos
signal q: std_logic_vector(1 downto 0);
-- signal de enable
signal en: std_logic;
-- signal de pulsador f
signal pulsaf: std_logic;
begin
	
	-- temporizador / contador
	process(clk,reset)
	
	begin
	-- el reset pone el circuito en estado inicial de manera asincrona
	if reset = '1' then
		 e_actual <= inicial;
		cuenta <= "000";
	-- el contador funciona de manera sincrona con el reloj
	elsif clk'event and clk='1' then
			e_actual <= e_sig;
		-- si la cuenta es 4 vuelve a cero y hace que fin de cuenta sea 1
		if cuenta = "100" then
			cuenta <= "000" ;
			fin_de_cuenta <= '1';
		-- si el enable no esta activado entonces la cuenta es 0 y fin de cuenta tambien
		elsif en = '0' then
			cuenta <= "000" ;
			fin_de_cuenta <= '0';
		-- sino se suma 1 a la cuenta y find de cuenta se vuelve 0
		else
			cuenta <= cuenta + "001";
			fin_de_cuenta <= '0';
			end if;
		end if;
	end process;
	-- la senial cuenta s es la cuenta en vector
	cuenta_s <= std_logic_vector(cuenta);
	


	-- maquina de estados
	process(e_actual, cuenta, pulsaf)
	begin
	case e_actual is 

	-- estado inicial
	-- no pasa nada hasta que no se pulse el pulsador
	when inicial =>
	-- valores del estado 
		verde <= '1';
		ambar <= '0';
		rojo <= '0';
		en <= '0';
		-- condiciones para pasar al siguiente estado
		if pulsaf = '0' then
			e_sig <= inicial;
		else
			en <= '1';
			e_sig <= v;
			
		end if;
	
	-- verde
	when v =>
	-- valores del estado 
		verde <= '1';
		ambar <= '0';
		rojo <= '0';
		en <= '1';
		-- condiciones para pasar al siguiente estado
		if cuenta = "100" then 
			e_sig <= a;
		else
			e_sig <= v;
		end if;
	
	-- amarillo
	when a =>
	-- valores del estado  
		verde <= '0';
		ambar <= '1';
		rojo <= '0';
		en <= '1';
		-- condiciones para pasar al siguiente estado
		if cuenta = "100" then 
			e_sig <= r;
		else
			e_sig <= a;
		end if;
	
	-- rojo
	when r =>
	-- valores del estado 
		verde <= '0';
		ambar <= '0';
		rojo <= '1';
		en <= '1';
		-- condiciones para pasar al siguiente estado
		if cuenta = "100" then
			en <= '0';
			e_sig <= inicial;

		else
			e_sig <= r;
		end if;
	-- when others no se usa pero necesario	
	when others =>
	verde <='1';
	ambar <= '0';
	rojo <= '0';
	en <= '0';
	e_sig <= inicial;
	end case;
	end process;
	
	
	-- detector de flancos
	-- es un registro en serie y luego se toma las dos seniales y se hace un and para encontrar el pulsaf
	process(pulsador, clk, reset)
	begin
	if reset  = '1' then
		q<= "00";
	elsif clk'event and clk = '1' then
		q(1) <= pulsador;
		q(0) <= q(1);
		pulsaf <= q(1) and not q(0);
	end if;
	end process;
	

	
	
	
end funcional;