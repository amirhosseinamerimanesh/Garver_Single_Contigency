function [P_line] = rundcpf(busdata, linedata)
    %% find line out
    line_out = find( linedata(:,7) == 0);
    linedata(line_out, :) = [];
    %% Create B matrix
    numbus = length( busdata(:,1) );
    numline = length( linedata(:,1) );
    slack_bus = 1;
    B = zeros(numbus);

    for i = 1:numline
        B( linedata(i,2), linedata(i,3) ) = -(1 / linedata(i,5) );
        B( linedata(i,3), linedata(i,2) ) = B( linedata(i,2), linedata(i,3) );
        B( linedata(i,2), linedata(i,2) ) = B( linedata(i,2), linedata(i,2) ) + (1 / linedata(i,5) );
        B( linedata(i,3), linedata(i,3) ) = B( linedata(i,3), linedata(i,3) ) + (1 / linedata(i,5) );
    end

    Y = B;
    B(:, slack_bus) = [];
    B(slack_bus, :) = [];
    B2 = inv(B);
    %% delta calculation
    gen = busdata(:, 3);
    load = busdata(:, 4);
    P = gen - load;
    P(slack_bus) = [];
    delta = B2*P;
    delta = [0; delta];
    %% Create A and b matrix
    for i = 1:numline
        A(i, linedata(i, 2) ) = 1;
        A(i, linedata(i, 3) ) = -1;
        b(i, i) = 1 / linedata(i, 5);
    end
    %% p line calculation
    P_line = b * A * delta;
    P_line = P_line';
end