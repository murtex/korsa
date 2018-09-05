
	% -----------------------------------------------------------------------
	% DO NOT EDIT ANYTHING HERE!
	% -----------------------------------------------------------------------

	% i/o
rawdir_ = fullfile( datadir_, 'raw/' );
procdir_ = fullfile( datadir_, project_ );
plotdir_ = fullfile( 'images/', project_ );

	% processing
pre_rate_ = 85;
pre_cutoff_ = 25;

seg_method_ = 'mwpca'; % [vert, roipca, mwpca]
seg_pca_ = 'inertia'; % [inertia, cov, svd]
seg_cycles_ = 1;
seg_spline_ = [5, 4, 3];
seg_tags_ = {'auto'};
seg_q_ = 0.2;

sel_filtin_ = seg_tags_;
sel_filtex_ = {};
sel_filtsel_ = {'gest'};
sel_brighten_ = 0.1;

	% sensors
sensbplate_ = {'frbp', 'lbp', 'rbp'};
senspalate_ = {'trace'};
sensref_ = {'lear', 'nose', 'rear', 'ui'};

senstongue_ = {'tb', 'tt'};
sensspeech_ = [senstongue_, 'jaw'];

senssag_ = [sensref_, sensspeech_];

sensaudio_ = {'audio'};
sensema_ = [sensbplate_, senspalate_, sensref_, sensspeech_];

	% axes
axaudio_ = {'ch1'};
axema_ = {'x', 'y', 'z'};
axsag_ = {'x', 'y'};
axvert_ = {'y'};

switch seg_method_
	case {'mwpca', 'roipca'}
		axpca_ = {'x'};
	case 'vert'
		axpca_ = axvert_;
	otherwise
		errror( 'invalid value: seg_method_' );
end

	% filters
trialdims_ = {'sensors', 'axes'};

filtaudio_ = {trialdims_, {sensaudio_, axaudio_}, true};
filtema_ = {trialdims_, {sensema_, axema_}, true};
filtsag_ = {trialdims_, {sensema_, axsag_}, true};
filtvert_ = {trialdims_, {sensema_, axvert_}, true};
filtpca_ = {trialdims_, {sensema_, axpca_}, true};

