
% RETO 3 - ALGORITMO DE CONTROL Y CARGAS
% Curso: Software para Ingenieria - UNAD
% Simulacion del balance energetico durante 24 horas

clc;
clear;
format short;

% 1. Definir las horas de simulacion
horas = 1:24;

% 2. Datos de generacion y demanda del Reto 2 (kW)
solar = [0 0 0 0 0 5 8 12 16 20 23 25 ...
         23 20 16 12 8 5 0 0 0 0 0 0];

eolica = [7 9 6 11 8 10 12 7 9 13 8 11 ...
          10 6 12 9 7 14 11 8 13 10 6 9];

demanda = [3 3 2 4 3 7 8 8 9 9 10 10 ...
           9 8 8 9 10 14 15 13 14 3 4 3];

% 3. Configurar los parametros de la bateria
capacidad_bat = 100;  % Capacidad total en kWh
SOC = 50;             % Estado de carga inicial en porcentaje
SOC_max = 100;        % Limite maximo de carga
SOC_min = 0;          % Limite minimo absoluto

% 4. Calcular la generacion hibrida y el balance
generacion = solar + eolica;
balance = generacion - demanda;

% 5. Mostrar el encabezado del reporte
fprintf('REPORTE DEL CONTROL ENERGETICO - 24 HORAS\n');
fprintf('SOC inicial: %.2f %%\n\n', SOC);
fprintf(['Hora | Generacion | Demanda | Balance | SOC | ' ...
         'Escuela | Bombeo | Alumbrado\n']);
fprintf(repmat('-', 1, 91));
fprintf('\n');

% 6. Recorrer cada hora de la simulacion
for i = 1:length(horas)

    % 6.1 Evaluar el balance energetico de la hora
    if balance(i) >= 0

        % Existe superavit: la energia sobrante carga la bateria
        excedente = balance(i);
        SOC = SOC + (excedente / capacidad_bat) * 100;

        % Evitar que la bateria supere el 100 %
        SOC = min(SOC, SOC_max);

        % Con superavit, todas las cargas permanecen activas
        escuela = 'ACTIVA';
        bombeo = 'ACTIVO';
        alumbrado = 'ACTIVO';

    else

        % Existe deficit: la bateria suministra energia faltante
        faltante = abs(balance(i));
        SOC = SOC - (faltante / capacidad_bat) * 100;

        % Evitar que el SOC sea inferior al 0 %
        SOC = max(SOC, SOC_min);

        % Aplicar la prioridad de las cargas segun el SOC
        if SOC > 40

            % Ruta segura: todas las cargas siguen funcionando
            escuela = 'ACTIVA';
            bombeo = 'ACTIVO';
            alumbrado = 'ACTIVO';

        elseif SOC > 20

            % Ruta de alerta: desconectar alumbrado publico
            escuela = 'ACTIVA';
            bombeo = 'ACTIVO';
            alumbrado = 'APAGADO';

        else

            % Ruta de emergencia: preservar la escuela rural
            escuela = 'ACTIVA';
            bombeo = 'APAGADO';
            alumbrado = 'APAGADO';

        end
    end

    % 6.2 Imprimir los resultados de la hora evaluada
    fprintf('%4d | %10.2f | %7.2f | %+7.2f | %5.2f%% | %7s | %7s | %9s\n', ...
        horas(i), generacion(i), demanda(i), balance(i), ...
        SOC, escuela, bombeo, alumbrado);

end

% 7. Informar el estado final de la bateria
fprintf('\nSOC final de la bateria: %.2f %%\n', SOC);
fprintf('Simulacion de 24 horas finalizada.\n');