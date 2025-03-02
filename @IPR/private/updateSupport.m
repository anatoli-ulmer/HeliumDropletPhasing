function support = updateSupport(w)
    nsup = abs(w);
    nsup = single(nsup>.15*max(nsup(:)));
    nsup = imgaussfilt(nsup, 3);
    nsup = nsup>.15;
    %             support = nsup>.1*max(nsup(:));
    support = nsup;
end