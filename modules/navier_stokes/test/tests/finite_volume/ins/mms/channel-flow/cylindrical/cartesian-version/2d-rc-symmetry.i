mu=1.1
rho=1.1

[Mesh]
  [gen]
    type = GeneratedMeshGenerator
    dim = 2
    xmin = 0
    xmax = 1
    ymin = -1
    ymax = 1
    nx = 2
    ny = 2
  []
[]

[Problem]
  fv_bcs_integrity_check = false
[]

[GlobalParams]
  rhie_chow_user_object = 'rc'
  two_term_boundary_expansion = true
  advected_interp_method = 'average'
  velocity_interp_method = 'rc'
[]

[UserObjects]
  [rc]
    type = INSFVRhieChowInterpolator
    u = u
    v = v
    pressure = pressure
  []
[]

[Variables]
  [u]
    type = INSFVVelocityVariable
  []
  [v]
    type = INSFVVelocityVariable
  []
  [pressure]
    type = INSFVPressureVariable
  []
[]

[ICs]
  [u]
    type = FunctionIC
    function = 'exact_u'
    variable = u
  []
  [v]
    type = FunctionIC
    function = 'exact_v'
    variable = v
  []
  [pressure]
    type = FunctionIC
    function = 'exact_p'
    variable = pressure
  []
[]

[FVKernels]
  [mass]
    type = INSFVMassAdvection
    variable = pressure
    rho = ${rho}
  []
  [mass_forcing]
    type = FVBodyForce
    variable = pressure
    function = forcing_p
  []

  [u_advection]
    type = INSFVMomentumAdvection
    variable = u
    rho = ${rho}
    momentum_component = 'x'
  []
  [u_viscosity]
    type = INSFVMomentumDiffusion
    variable = u
    mu = ${mu}
    momentum_component = 'x'
  []
  [u_pressure]
    type = INSFVMomentumPressure
    variable = u
    momentum_component = 'x'
    pressure = pressure
  []
  [u_forcing]
    type = INSFVBodyForce
    variable = u
    functor = forcing_u
    momentum_component = 'x'
  []

  [v_advection]
    type = INSFVMomentumAdvection
    variable = v
    rho = ${rho}
    momentum_component = 'y'
  []
  [v_viscosity]
    type = INSFVMomentumDiffusion
    variable = v
    mu = ${mu}
    momentum_component = 'y'
  []
  [v_pressure]
    type = INSFVMomentumPressure
    variable = v
    momentum_component = 'y'
    pressure = pressure
  []
  [v_forcing]
    type = INSFVBodyForce
    variable = v
    functor = forcing_v
    momentum_component = 'y'
  []
[]

[FVBCs]
  [u_wall]
    type = INSFVNoSlipWallBC
    variable = u
    boundary = 'right'
    function = 'exact_u'
  []
  [v_wall]
    type = INSFVNoSlipWallBC
    variable = v
    boundary = 'right'
    function = 'exact_v'
  []
  [u_axis]
    type = INSFVSymmetryVelocityBC
    variable = u
    boundary = 'left'
    mu = ${mu}
    u = u
    v = v
    momentum_component = 'x'
  []
  [v_axis]
    type = INSFVSymmetryVelocityBC
    variable = v
    boundary = 'left'
    mu = ${mu}
    u = u
    v = v
    momentum_component = 'y'
  []
  [p_axis]
    type = INSFVSymmetryPressureBC
    variable = pressure
    boundary = 'left'
  []
  [p]
    type = INSFVOutletPressureBC
    variable = pressure
    function = 'exact_p'
    boundary = 'top'
  []
  [inlet_u]
    type = INSFVInletVelocityBC
    variable = u
    function = 'exact_u'
    boundary = 'bottom'
  []
  [inlet_v]
    type = INSFVInletVelocityBC
    variable = v
    function = 'exact_v'
    boundary = 'bottom'
  []
[]

[Functions]
  [exact_u]
    type = ParsedFunction
    expression = 'sin(x*pi)*cos(y*pi)'
  []
  [forcing_u]
    type = ADParsedFunction
    expression = '2*pi^2*mu*sin(x*pi)*cos(y*pi) - 2*pi*rho*sin(x*pi)*sin(y*pi)*cos(1.3*x)*cos(y*pi) + 2*pi*rho*sin(x*pi)*cos(x*pi)*cos(y*pi)^2 - 1.5*sin(1.5*x)*cos(1.6*y)'
    symbol_names = 'mu rho'
    symbol_values = '${mu} ${rho}'
  []
  [exact_v]
    type = ParsedFunction
    expression = 'cos(1.3*x)*cos(y*pi)'
  []
  [forcing_v]
    type = ADParsedFunction
    expression = '1.69*mu*cos(1.3*x)*cos(y*pi) + pi^2*mu*cos(1.3*x)*cos(y*pi) - 1.3*rho*sin(1.3*x)*sin(x*pi)*cos(y*pi)^2 - 2*pi*rho*sin(y*pi)*cos(1.3*x)^2*cos(y*pi) + pi*rho*cos(1.3*x)*cos(x*pi)*cos(y*pi)^2 - 1.6*sin(1.6*y)*cos(1.5*x)'
    symbol_names = 'mu rho'
    symbol_values = '${mu} ${rho}'
  []
  [exact_p]
    type = ParsedFunction
    expression = 'cos(1.5*x)*cos(1.6*y)'
  []
  [forcing_p]
    type = ParsedFunction
    expression = '-pi*rho*sin(y*pi)*cos(1.3*x) + pi*rho*cos(x*pi)*cos(y*pi)'
    symbol_names = 'rho'
    symbol_values = '${rho}'
  []
[]

[Executioner]
  type = Steady
  solve_type = 'NEWTON'
  petsc_options_iname = '-pc_type -pc_factor_shift_type -pc_factor_mat_solver_type'
  petsc_options_value = 'lu       NONZERO               superlu_dist'
  line_search = 'none'
  nl_rel_tol = 1e-12
  nl_abs_tol = 1e-12
[]

[Outputs]
  exodus = false
  csv = true
[]

[Postprocessors]
  [h]
    type = AverageElementSize
    outputs = 'console csv'
    execute_on = 'timestep_end'
  []
  [./L2u]
    type = ElementL2Error
    variable = u
    function = exact_u
    outputs = 'console csv'
    execute_on = 'timestep_end'
  [../]
  [./L2v]
    type = ElementL2Error
    variable = v
    function = exact_v
    outputs = 'console csv'
    execute_on = 'timestep_end'
  [../]
  [./L2p]
    variable = pressure
    function = exact_p
    type = ElementL2Error
    outputs = 'console csv'
    execute_on = 'timestep_end'
  [../]
  [p_avg]
    type = ElementAverageValue
    variable = pressure
    outputs = 'console csv'
    execute_on = 'timestep_end'
  []
[]
