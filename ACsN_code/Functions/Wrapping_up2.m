function output = Wrapping_up2(input,sigma,alpha)

M1 = max(max(input));
M2 = min(min(input));
beta = mean(sigma).*alpha;
input = (input - M2)./(M1 -M2);
input = Merge(input,beta); 
output = (input).*(M1-M2)+ M2;

end