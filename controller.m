
function [phi, Dir] = controller(Leftposition,Rightposition)
%inverse projection
Fu = 730.85;
Fv = 731.66;
u0 = 626.7;
v0 = 471;
Yc = 210;
Dir = 0;
    for i=1:2
        if i == 1
            Zclf = Fv*Yc/(Leftposition(1,2)-v0);
            Xclf = Zclf*(Leftposition(1,1)-u0)/Fu;
        else
            Zcln = Fv*Yc/(Leftposition(1,4)-v0);
            Xcln = Zcln*(Leftposition(1,3)-u0)/Fu;
        end
    end
%Coor_left = [Xclf Xcln;Zclf Zcln];
    for i=1:2
        if i == 1
            Zcrf = Fv*Yc/(Rightposition(1,2)-v0);
            Xcrf = Zclf*(Rightposition(1,1)-u0)/Fu;
        else
            Zcrn = Fv*Yc/(Rightposition(1,4)-v0);
            Xcrn = Zcln*(Rightposition(1,3)-u0)/Fu;
        end
    end
%Coor_right = [Xcrf Xcrn;Zcrf Zcrn];
   
    %Stanley
    Cpo = 60;
    Xcf = 0.5*(Xcrf+Xclf); %center line far X-coordinate
    Zcf = 0.5*(Zcrf+Zclf); %center line far Z-coordinate
     Xcn = 0.5*(Xcrn+Xcln); %center line near X-coordinate
    Zcn = 0.5*(Zcrn+Zcln); %center line Near Z-coordinate
   
    dep_ang = 180/pi*(-atan((Zcf-Zcn)/(Xcf-Xcn)))-90;    %departure Angle
    dep_dis = Xcn + ((Xcf-Xcn)/(Zcf-Zcn))*(Zcn-Cpo);   %departure distance
    k1=1;
    k2=-0.8281;
    phi=k1*dep_ang-k2*dep_dis;
    phi = round(phi);
    if phi > 0
        Dir = 2; % Left
    elseif phi < 0
        Dir = 1; % Right
    else 
        Dir = 0; % Straight
    end
        
    
