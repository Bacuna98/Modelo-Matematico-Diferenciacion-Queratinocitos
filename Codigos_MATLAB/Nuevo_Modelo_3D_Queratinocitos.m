%% CODIGO PROYECTO LAB MODELACIÓN 2. 
% Optimiza el modelo de diferenciación de queratinocitos usando datos
% experimentales, simula el modelo optimizado y evalúa el punto de
% equilibrio

% limpiamos el espacio de trabajo
close all
clear all
clc


tic % empezamos a tomar el tiempo

% Datos experimentales [añadir ref]

tex= [0 5 10 15 20 25 30 35 40 45]; %tiempo 
p53ex= [8.293 8.102333333 7.561 7.208666667 7.382333333 7.640666667 7.760666667 7.893333333 8.142 8.301333333];
Stat3ex= [10.32066667 10.96533333 11.15966667 11.16066667 11.167 11.006 10.75666667 10.59766667 10.35066667 10.505];
Np63ex= [7.721333333 7.14 6.675 6.946333333 7.060333333 6.731666667 6.723666667 6.757 6.810666667 6.883333333];

% Parameters - primeros estimados

% Valores de p53
% dp53 = (Pp53 + B*(p53^N)/(k^N+p53^N) + ANp63p53*Np63)*C1*(1/(1+dNp63p53*Np63))-p53*Dp53;
Pp53 = 1; % Producción basal de p53 
N = 1; % Exponente de Hill
k = 1; % Constante de saturacion
B = 1; % Coeficiente retroalimentacion positiva
ANp63p53 = 1; % Efecto de Np63 sobre p53 sobre transcripcion positiva
C1 = 1; % Coeficiente transcripcion negativa
dNp63p53 = 1; % Efecto de np63 sobre p53 - transcripcion negativa
Dp53 = 1; % Degradacion basal de p53

% Valores de stat3
% dStat3 = (Pstat3 + ANp63s*Np63 + Ap53s*p53) - Dstat3*Stat3;
Pstat3 = 1; % Produccion basal de stat3
ANp63s = 1; % Efecto de Np63 sobre stat3 - transcripcion
Ap53s = 1; % Efecto de p53 sobre stat3 - transcripcion
Dstat3 = 1; % degradacion basal de stat3

% Valores de Np63
% dNp63 = (PNp63 + Astat3Np*Stat3)*C2*(1/(1+dp53NP*p53))*C3*(1/(1+dNp63Np63*Np63)) - DNp63*Np63;
PNp63 = 10; % Produccion basal de p63
Astat3Np = 1; % Efecto de Stat3 sobre Np63 - transcripacion
C2 = 1; % Coeficiente transcripcion negativa
dp53NP = 1; % Efecto de p53 sobre Np63 - transcripcion negativa
C3 = 1; % Coeficiente transcripcion negativa
dNp63Np63 = 1; % Efecto de Np63 sobre si misma - transcripcion negativa
DNp63 = 5; % Degradacion basal de p63 

% Intervalo de tiempo y condiciones iniciales
tspan = [0 50]; 
y0 = [p53ex(1) Stat3ex(1) Np63ex(1) ]; 

% Los valores de estos parametros los metemos a un vector, que es el primer estimado de los valores de parameteros
x0 = [Pp53, N, k, B, ANp63p53, C1, dNp63p53, Dp53, Pstat3, ANp63s, Ap53s, Dstat3, PNp63, Astat3Np, C2, dp53NP, C3, dNp63Np63, DNp63];

% Llamas a una funcion de COSTO. y graficas

Plot_with_data('primer estimado', x0,tex,p53ex,Stat3ex,Np63ex,y0, tspan)


%             
function Cost = CostFunction_keratinocytes(x,tex,p53ex,Stat3ex,Np63ex,y0, tspan)
    % FUNCION DE COSTO: LE DAS PARAMETROS Y TE REGRESA LA DIFERENCIA ENTRE MODELO Y DATOS EXPERIMENTALES
                            % x: el vector de parametros 
                            % tex: es el tiempo en el que se hicieron las mediciones
                            % data: son las mediciones experimentales de las variables . 
                            % DADO QUE TU TIENES MEDICIONES PARA MAS DE UNA VARIABLE, TE RECOMIENDO QUE SE LAS METAS ASI EXPLICITAMENTE, POR EJEMPLO, COMO STAT3_EXP, P53_EXP, UNA POR UNA
                            % y0: tu condicion inical
                            % tspan el intervalo de integracion
                            % EN ESTE EJEMPLO VARIOS PARAMETROS LOS DEJE FIJOS,
                            % SIN OPTIMIZAR PERO TU VAS A OPTIMIZAR TODOS, ASI
                            % QUE NO SERA NECESARIO PASARLE PARAMETEROS
                            % ADICIONALES
    % (1) DADOS LOS PARAMETROS (x), correr (integrar numericamente) el modelo
    
    %Parameters - mucho cuidado con el orden

    % Extraccion de parametros
        Pp53 = x(1); N = x(2); k = x(3); B = x(4); ANp63p53 = x(5); C1 = x(6); dNp63p53 = x(7); Dp53 = x(8);
        Pstat3 = x(9); ANp63s = x(10); Ap53s = x(11); Dstat3 = x(12);
        PNp63 = x(13); Astat3Np = x(14); C2 = x(15); dp53NP = x(16); C3 = x(17); dNp63Np63 = x(18); DNp63= x(19);
    
    % define las condiciones iniciales (TU SE LO VAS A PASAR DIRECTAMENTE A LA
    % FUNCION, NO NECESIDAD DE CALCULAR COMO LO HAGO YO)
    
    
    % We integrate the model
     Sol=ode15s(@(t, y)difer(t, y,  B, Pp53, Pstat3, PNp63, N, k, ANp63p53, C1, dNp63p53, Dp53, ANp63s, Ap53s, Dstat3, Astat3Np, C2, dp53NP, C3, dNp63Np63, DNp63), tspan, y0);
                         
    % De la simulacion del modelo, extrae los valores que vas a comparar con los datos experimentales
    t1=Sol.x; % es esl tiempo
    p53=Sol.y(1,:); % variable 1
    Stat3=Sol.y(2,:); % variable 2
    Np63 =Sol.y(3,:); % variable 3
      
    % Predictions
    
    % interpolate those values corresponding to the experiments
    % t1: el tiempo simulado
    % EDC_t: es la solucin simulada de tu variable para la cual tienes datos
    % t_exp es el tiempo en el que se hizo la medicion
    %EDC_pre_Interpol= interp1(t1,EDC_t,t_exp); % VALOR DE MODELO QUE VAS A COMPARAR 
    
     p53_interp = interp1(t1,p53,tex);
     Stat3_interp = interp1(t1,Stat3,tex);
     Np63_interp = interp1(t1,Np63,tex);
    
    % Calculate the cost of the predition vs. the experimental data
    % ESTO ES PARA UNA VARIABLE NADAMAS
    % DATA ES EL VALOR DE LA VARIABLE (EDC) QUE VAS A COMPARAR CON LA
    % SIMUALCION
    %Cost=sqrt(sum((EDC_pre_Interpol-data).^2));%./length(data);
    Cost_p53=sqrt(sum(( p53_interp -p53ex).^2));
    Cost_Stat3=sqrt(sum(( Stat3_interp -Stat3ex).^2));
    Cost_Np63=sqrt(sum(( Np63_interp -Np63ex).^2));
    Cost =(Cost_p53+Cost_Stat3+Cost_Np63);
end

% ODE funcion 
function dx = difer(t, y,  B, Pp53, Pstat3, PNp63, N, k, ANp63p53, C1, dNp63p53, Dp53, ANp63s, Ap53s, Dstat3, Astat3Np, C2, dp53NP, C3, dNp63Np63, DNp63);
    p53 = y(1); 
    Stat3 = y(2); 
    Np63 = y(3); 
    
    dp53      = ( Pp53 + B*(p53^N)/(k^N+p53^N) + ANp63p53*Np63)*C1*(1/(1+dNp63p53*Np63))-p53*Dp53;
    
    dStat3    = (Pstat3 + ANp63s*Np63 + Ap53s*p53) - Dstat3*Stat3;
    
    dNp63     = (PNp63 + Astat3Np*Stat3)*C2*(1/(1+dp53NP*p53))*C3*(1/(1+dNp63Np63*Np63)) - DNp63*Np63;
    
    dx = [dp53;dStat3;dNp63];
end


function  Plot_with_data(label, x,tex,p53ex,Stat3ex,Np63ex, y0, tspan)

    Cost = CostFunction_keratinocytes(x,tex,p53ex,Stat3ex,Np63ex, y0, tspan);
    
    % Extraccion de parametros
    Pp53 = x(1); N = x(2); k = x(3); B = x(4); ANp63p53 = x(5); C1 = x(6); dNp63p53 = x(7); Dp53 = x(8);
    Pstat3 = x(9); ANp63s = x(10); Ap53s = x(11); Dstat3 = x(12);
    PNp63 = x(13); Astat3Np = x(14); C2 = x(15); dp53NP = x(16); C3 = x(17); dNp63Np63 = x(18); DNp63= x(19);

    [ts,y] = ode15s(@(t, y) difer(t, y, B, Pp53, Pstat3, PNp63, N, k, ANp63p53, C1, dNp63p53, Dp53, ANp63s, Ap53s, Dstat3, Astat3Np, C2, dp53NP, C3, dNp63Np63, DNp63), tspan, y0);
    
    figure;
    % Trayectorias dinamicas 
    l1=plot(ts, y(:,1), 'r', 'DisplayName', 'p53');
    hold on
    l2=plot(ts, y(:,2), 'b', 'DisplayName', 'Stat3');
    l3=plot(ts, y(:,3), 'g', 'DisplayName', 'Np63');
    xlabel('Tiempo [horas]')
    ylabel('Concentración [u.a.]')
    xlim([0, 50])
    scatter(tex, p53ex, 'r', 'DisplayName', 'p53 experimental')
    scatter(tex, Stat3ex, 'b', 'DisplayName', 'Stat3 experimental')
    scatter(tex, Np63ex, 'g', 'DisplayName', 'Np63 experimental')
    if (sum((x)<0)>0) % there are negative values
        title(['!! x has NEGATIVE VALUES ' label  'Cost=' num2str(Cost) ])%; 'x=' num2str(x) ])
    else
        title([label ' cost ' num2str(Cost) ])%; 'x=' num2str(x) ])
    end
    legend off
    % puntos de equ
    Equilibrios_modelo_shamari(x)
    
    ySS=Equilibrios_modelo_shamari(x);
    
    
    for jj=1:1: length(ySS(:,1))
        % select only positive
        if sum((ySS(jj,:)<0))==0
            scatter(ts(end), ySS(jj,1), 25, 'r', 'filled')
            scatter(ts(end), ySS(jj,2), 25, 'b', 'filled')
            scatter(ts(end), ySS(jj,3), 25, 'g', 'filled')
        end
    end
    ylim([0, 20])
    axis square
    hold off
    
    legend([l1, l2 l3], 'p53', 'Stat3','Np63');

end

function Steady_states=Equilibrios_modelo_shamari(x)
    % Extraccion de parametros
    Pp53 = x(1); N = x(2); k = x(3); B = x(4); ANp63p53 = x(5); C1 = x(6); dNp63p53 = x(7); Dp53 = x(8);
    Pstat3 = x(9); ANp63s = x(10); Ap53s = x(11); Dstat3 = x(12);
    PNp63 = x(13); Astat3Np = x(14); C2 = x(15); dp53NP = x(16); C3 = x(17); dNp63Np63 = x(18); DNp63= x(19);
    
    % análisis de equilibios
    syms p53 Stat3 Np63 

    dp53      =0== ( Pp53 + B*(p53^N)/(k^N+p53^N) + ANp63p53*Np63)*C1*(1/(1+dNp63p53*Np63))-p53*Dp53;
    
    dStat3    =0== (Pstat3 + ANp63s*Np63 + Ap53s*p53) - Dstat3*Stat3;
   
    dNp63     =0== (PNp63 + Astat3Np*Stat3)*C2*(1/(1+dp53NP*p53))*C3*(1/(1+dNp63Np63*Np63)) - DNp63*Np63;
    
    equations = [dp53 dStat3 dNp63];
    vars       =[p53  Stat3   Np63];
    
    range = [NaN NaN; NaN NaN;NaN NaN];
    sol = vpasolve(equations, vars, range);
    
    Steady_states=double([sol.p53 sol.Stat3 sol.Np63]);
end