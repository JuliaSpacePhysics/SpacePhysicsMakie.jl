@testitem "Speasy integration" begin
    using SpacePhysicsMakie: labels
    using Speasy

    data = let intervals = ["2019-01-02T15", "2019-01-02T16"], spz = speasy
        products = [
            spz.inventories.tree.cda.MMS.MMS1.FGM.MMS1_FGM_SRVY_L2.mms1_fgm_b_gse_srvy_l2_clean,
            spz.inventories.tree.cda.MMS.MMS1.DES.MMS1_FPI_FAST_L2_DES_MOMS.mms1_des_energyspectr_omni_fast,
        ]
        Speasy.get_data(products, intervals)
    end

    # Test that data was retrieved
    @test axis_attributes(data[1]) == Dict{Symbol, Any}(:yscale => identity, :ylabel => "mms1_fgm_b_gse_srvy_l2_clean\n(nT)")
    @test labels(data[1]) == ["Bx GSE", "By GSE", "Bz GSE", "Bt    "]
    @test axis_attributes(data[2]) == Dict{Symbol, Any}(:yscale => log10, :ylabel => "energy\n(eV)")
end
