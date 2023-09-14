function tau = TLR(M,alt,BPR)
arguments
    M
    alt
    BPR
end
%TLR Thrust lapse ratio as per Howe 2000 Aircraft Conceptual Design
%Synthesis p.67
[~,~,~,~,~,~,sigma] = cast.util.atmos(alt);

if BPR >=8
    ks = [1 0 -0.595 -0.03;0.89 -0.014 -0.3 0.005];
    s = 0.7;
elseif BPR>=3
    ks = [0.88,-0.016, -0.3, 0;1 0 -0.6 -0.04];
    s = 0.7;
else
    ks = [1 0 -0.2 0.07; 0.856 0.062 0.16 -0.23];
    s = 0.8;
end

if M>0.4
    k = ks(2,:);
else
    k = ks(1,:);
end

if alt>11e3
    s=1;
end

tau = sigma.^s.*(k(1)+k(2)*BPR+M*(k(3)+k(4)*BPR));
end

