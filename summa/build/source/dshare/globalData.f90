! SUMMA - Structure for Unifying Multiple Modeling Alternatives
! Copyright (C) 2014-2015 NCAR/RAL
!
! This file is part of SUMMA
!
! For more information see: http://www.ral.ucar.edu/projects/summa
!
! This program is free software: you can redistribute it and/or modify
! it under the terms of the GNU General Public License as published by
! the Free Software Foundation, either version 3 of the License, or
! (at your option) any later version.
!
! This program is distributed in the hope that it will be useful,
! but WITHOUT ANY WARRANTY; without even the implied warranty of
! MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
! GNU General Public License for more details.
!
! You should have received a copy of the GNU General Public License
! along with this program.  If not, see <http://www.gnu.org/licenses/>.

MODULE globalData
 ! data types
 USE nrtype
 USE,intrinsic :: ieee_arithmetic    ! IEEE arithmetic
 USE data_types,only:gru2hru_map     ! mapping between the GRUs and HRUs
 USE data_types,only:hru2gru_map     ! mapping between the GRUs and HRUs
 USE data_types,only:model_options   ! the model decision structure
 USE data_types,only:file_info       ! metadata for model forcing datafile
 USE data_types,only:par_info        ! default parameter values and parameter bounds
 USE data_types,only:var_info        ! metadata for variables in each model structure
 USE data_types,only:flux2state      ! extended metadata to define flux-to-state mapping
 USE data_types,only:extended_info   ! extended metadata for variables in each model structure
 USE data_types,only:struct_info     ! summary information on all data structures
 USE data_types,only:var_i           ! vector of integers
 ! number of variables in each data structure
 USE var_lookup,only:maxvarTime      ! time:                     maximum number variables
 USE var_lookup,only:maxvarForc      ! forcing data:             maximum number variables
 USE var_lookup,only:maxvarAttr      ! attributes:               maximum number variables
 USE var_lookup,only:maxvarType      ! type index:               maximum number variables
 USE var_lookup,only:maxvarProg      ! prognostic variables:     maximum number variables
 USE var_lookup,only:maxvarDiag      ! diagnostic variables:     maximum number variables
 USE var_lookup,only:maxvarFlux      ! model fluxes:             maximum number variables
 USE var_lookup,only:maxvarDeriv     ! model derivatives:        maximum number variables
 USE var_lookup,only:maxvarIndx      ! model indices:            maximum number variables
 USE var_lookup,only:maxvarMpar      ! model parameters:         maximum number variables
 USE var_lookup,only:maxvarBvar      ! basin-average variables:  maximum number variables
 USE var_lookup,only:maxvarBpar      ! basin-average parameters: maximum number variables
 USE var_lookup,only:maxvarDecisions ! maximum number of decisions
 USE var_lookup,only:maxvarFreq      ! maximum number of output files
 implicit none
 private

 ! define missing values
 real(qp),parameter,public                   :: quadMissing    = nr_quadMissing    ! (from nrtype) missing quadruple precision number
 real(dp),parameter,public                   :: realMissing    = nr_realMissing    ! (from nrtype) missing double precision number
 integer(i4b),parameter,public               :: integerMissing = nr_integerMissing ! (from nrtype) missing integer

 ! define run modes
 integer(i4b),parameter,public               :: iRunModeFull=1             ! named variable defining running mode as full run (all GRUs)
 integer(i4b),parameter,public               :: iRunModeGRU=2              ! named variable defining running mode as GRU-parallelization run (GRU subset)
 integer(i4b),parameter,public               :: iRunModeHRU=3              ! named variable defining running mode as single-HRU run (ONE HRU)

 ! define limit checks
 real(dp),parameter,public                   :: verySmall=tiny(1.0_dp)  ! a very small number
 real(dp),parameter,public                   :: veryBig=1.e+20_dp       ! a very big number

 ! define Indian bread (NaN)
 real(dp),save,public                        :: dNaN

 ! define algorithmic control parameters
 real(dp),parameter,public                   :: dx = 1.e-8_dp            ! finite difference increment

 ! Define the model decisions
 type(model_options),save,public             :: model_decisions(maxvarDecisions)  ! the model decision structure

 ! Define metadata for model forcing datafile
 type(file_info),save,public,allocatable     :: forcFileInfo(:)         ! file info for model forcing data

 ! define default parameter values and parameter bounds
 type(par_info),save,public                  :: localParFallback(maxvarMpar) ! local column default parameters
 type(par_info),save,public                  :: basinParFallback(maxvarBpar) ! basin-average default parameters

 ! define vectors of metadata
 type(var_info),save,public                  :: time_meta(maxvarTime)   ! model time information
 type(var_info),save,public                  :: forc_meta(maxvarForc)   ! model forcing data
 type(var_info),save,public                  :: attr_meta(maxvarAttr)   ! local attributes
 type(var_info),save,public                  :: type_meta(maxvarType)   ! local classification of veg, soil, etc.
 type(var_info),save,public                  :: mpar_meta(maxvarMpar)   ! local model parameters for each HRU
 type(var_info),save,public                  :: indx_meta(maxvarIndx)   ! local model indices for each HRU
 type(var_info),save,public                  :: prog_meta(maxvarProg)   ! local state variables for each HRU
 type(var_info),save,public                  :: diag_meta(maxvarDiag)   ! local diagnostic variables for each HRU
 type(var_info),save,public                  :: flux_meta(maxvarFlux)   ! local model fluxes for each HRU
 type(var_info),save,public                  :: deriv_meta(maxvarDeriv) ! local model derivatives for each HRU
 type(var_info),save,public                  :: bpar_meta(maxvarBpar)   ! basin parameters for aggregated processes
 type(var_info),save,public                  :: bvar_meta(maxvarBvar)   ! basin variables for aggregated processes

 ! ancillary metadata structures
 type(flux2state),   save,public             :: flux2state_orig(maxvarFlux)  ! named variables for the states affected by each flux (original)
 type(flux2state),   save,public             :: flux2state_liq(maxvarFlux)   ! named variables for the states affected by each flux (liquid water)
 type(extended_info),save,public,allocatable :: averageFlux_meta(:)          ! timestep-average model fluxes

 ! define summary information on all data structures
 integer(i4b),parameter                      :: nStruct=12              ! number of data structures
 type(struct_info),parameter,public,dimension(nStruct) :: structInfo=(/&
                   struct_info('time',  'TIME' , maxvarTime ), &        ! the time data structure
                   struct_info('forc',  'FORCE', maxvarForc ), &        ! the forcing data structure
                   struct_info('attr',  'ATTR' , maxvarAttr ), &        ! the attribute data structure
                   struct_info('type',  'TYPE' , maxvarType ), &        ! the type data structure
                   struct_info('mpar',  'PARAM', maxvarMpar ), &        ! the model parameter data structure
                   struct_info('bpar',  'BPAR' , maxvarBpar ), &        ! the basin parameter data structure
                   struct_info('bvar',  'BVAR' , maxvarBvar ), &        ! the basin variable data structure
                   struct_info('indx',  'INDEX', maxvarIndx ), &        ! the model index data structure
                   struct_info('prog',  'PROG',  maxvarProg ), &        ! the prognostic (state) variable data structure
                   struct_info('diag',  'DIAG' , maxvarDiag ), &        ! the diagnostic variable data structure
                   struct_info('flux',  'FLUX' , maxvarFlux ), &        ! the flux data structure
                   struct_info('deriv', 'DERIV', maxvarDeriv) /)        ! the model derivative data structure

 ! define named variables for "yes" and "no"
 integer(i4b),parameter,public               :: no=0                    ! .false.
 integer(i4b),parameter,public               :: yes=1                   ! .true.

 ! define named variables to describe the domain type
 integer(i4b),parameter,public               :: iname_cas =1000         ! named variable to denote a canopy air space state variable
 integer(i4b),parameter,public               :: iname_veg =1001         ! named variable to denote a vegetation state variable
 integer(i4b),parameter,public               :: iname_soil=1002         ! named variable to denote a soil layer
 integer(i4b),parameter,public               :: iname_snow=1003         ! named variable to denote a snow layer
 integer(i4b),parameter,public               :: iname_aquifer=1004      ! named variable to denote a snow layer

 ! define named variables to describe the state varible type
 integer(i4b),parameter,public               :: iname_nrgCanair=2001    ! named variable defining the energy of the canopy air space
 integer(i4b),parameter,public               :: iname_nrgCanopy=2002    ! named variable defining the energy of the vegetation canopy
 integer(i4b),parameter,public               :: iname_watCanopy=2003    ! named variable defining the mass of total water on the vegetation canopy
 integer(i4b),parameter,public               :: iname_liqCanopy=2004    ! named variable defining the mass of liquid water on the vegetation canopy
 integer(i4b),parameter,public               :: iname_nrgLayer=3001     ! named variable defining the energy state variable for snow+soil layers
 integer(i4b),parameter,public               :: iname_watLayer=3002     ! named variable defining the total water state variable for snow+soil layers
 integer(i4b),parameter,public               :: iname_liqLayer=3003     ! named variable defining the liquid  water state variable for snow+soil layers
 integer(i4b),parameter,public               :: iname_matLayer=3004     ! named variable defining the matric head state variable for soil layers
 integer(i4b),parameter,public               :: iname_lmpLayer=3005     ! named variable defining the liquid matric potential state variable for soil layers
 integer(i4b),parameter,public               :: iname_watAquifer=3006   ! named variable defining the water storage in the aquifer

 ! define named variables to describe the form and structure of the band-diagonal matrices used in the numerical solver
 ! NOTE: This indexing scheme provides the matrix structure expected by lapack. Specifically, lapack requires kl extra rows for additional storage.
 !       Consequently, all indices are offset by kl and the total number of bands for storage is 2*kl+ku+1 instead of kl+ku+1.
 integer(i4b),parameter,public               :: nRHS=1                  ! number of unknown variables on the RHS of the linear system A.X=B
 integer(i4b),parameter,public               :: ku=3                    ! number of super-diagonal bands
 integer(i4b),parameter,public               :: kl=4                    ! number of sub-diagonal bands
 integer(i4b),parameter,public               :: ixDiag=kl+ku+1          ! index for the diagonal band
 integer(i4b),parameter,public               :: nBands=2*kl+ku+1        ! length of the leading dimension of the band diagonal matrix

 ! define named variables for the type of matrix used in the numerical solution.
 integer(i4b),parameter,public               :: ixFullMatrix=1001       ! named variable for the full Jacobian matrix
 integer(i4b),parameter,public               :: ixBandMatrix=1002       ! named variable for the band diagonal matrix

 ! define indices describing the first and last layers of the Jacobian to print (for debugging)
 integer(i4b),parameter,public               :: iJac1=16                 ! first layer of the Jacobian to print
 integer(i4b),parameter,public               :: iJac2=20                 ! last layer of the Jacobian to print

 ! define indices describing the indices of the first and last HRUs in the forcing file
 integer(i4b),save,public                    :: ixHRUfile_min           ! minimum index
 integer(i4b),save,public                    :: ixHRUfile_max           ! maximum index

 ! define mapping structures
 type(gru2hru_map),allocatable,save,public   :: gru_struc(:)            ! gru2hru map
 type(hru2gru_map),allocatable,save,public   :: index_map(:)            ! hru2gru map

 ! define variables used for the vegetation phenology
 real(dp),dimension(12), save     , public   :: greenVegFrac_monthly    ! fraction of green vegetation in each month (0-1)
 logical(lgt)          , parameter, public   :: overwriteRSMIN=.false.  ! flag to overwrite RSMIN
 integer(i4b)          , parameter, public   :: maxSoilLayers=10000     ! Maximum Number of Soil Layers

 ! define common variables
 integer(i4b),save,public                    :: numtim                  ! number of time steps
 real(dp),save,public                        :: data_step               ! time step of the data
 real(dp),save,public                        :: refJulday               ! reference time in fractional julian days
 real(dp),save,public                        :: refJulday_data          ! reference time in fractional julian days (data files)
 real(dp),save,public                        :: fracJulday              ! fractional julian days since the start of year
 real(dp),save,public                        :: dJulianStart            ! julian day of start time of simulation
 real(dp),save,public                        :: dJulianFinsh            ! julian day of end time of simulation
 integer(i4b),save,public                    :: nHRUfile                ! number of HRUs in the file
 integer(i4b),save,public                    :: yearLength              ! number of days in the current year
 integer(i4b),save,public                    :: urbanVegCategory        ! vegetation category for urban areas
 logical(lgt),save,public                    :: doJacobian=.false.      ! flag to compute the Jacobian
 logical(lgt),save,public                    :: globalPrintFlag=.false. ! flag to compute the Jacobian

 ! define ancillary data structures
 type(var_i),save,public                     :: refTime                 ! reference time for the model simulation
 type(var_i),save,public                     :: startTime               ! start time for the model simulation
 type(var_i),save,public                     :: finshTime               ! end time for the model simulation

 ! output file information
 logical(lgt),dimension(maxvarFreq),save,public :: outFreq              ! true if the outut frequency is desired
 integer(i4b),dimension(maxvarFreq),save,public :: ncid                 ! netcdf output file id

END MODULE globalData
