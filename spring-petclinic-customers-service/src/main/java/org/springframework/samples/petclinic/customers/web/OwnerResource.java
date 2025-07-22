package org.springframework.samples.petclinic.customers.web;

import io.micrometer.core.instrument.MeterRegistry;
import io.micrometer.core.instrument.Timer;
import io.micrometer.core.annotation.Timed;
import io.micrometer.core.annotation.Counted;
import jakarta.validation.Valid;
import jakarta.validation.constraints.Min;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.samples.petclinic.customers.web.mapper.OwnerEntityMapper;
import org.springframework.samples.petclinic.customers.model.Owner;
import org.springframework.samples.petclinic.customers.model.OwnerRepository;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;
import java.util.concurrent.TimeUnit;

@RequestMapping("/owners")
@RestController
@Timed("timed.petclinic.owner")
@Counted(value = "counted.petclinic.owner")
class OwnerResource {

    private static final Logger log = LoggerFactory.getLogger(OwnerResource.class);

    private final OwnerRepository ownerRepository;
    private final OwnerEntityMapper ownerEntityMapper;
    private final MeterRegistry meterRegistry;

    OwnerResource(OwnerRepository ownerRepository, OwnerEntityMapper ownerEntityMapper, MeterRegistry meterRegistry) {
        this.ownerRepository = ownerRepository;
        this.ownerEntityMapper = ownerEntityMapper;
        this.meterRegistry = meterRegistry;
    }

    /**
     * Create Owner
     */
    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public Owner createOwner(@Valid @RequestBody OwnerRequest ownerRequest) {
        log.info("Creating owner with firstName: {}, lastName: {}", ownerRequest.firstName(), ownerRequest.lastName());
        return Timer
            .builder("custom.petclinic.owner.create.latency")
            .description("Latency of create owner action")
            .register(meterRegistry)
            .record(() -> {
                Owner owner = ownerEntityMapper.map(new Owner(), ownerRequest);
                return ownerRepository.save(owner);
            });
    }

    /**
     * Read single Owner
     */
    @GetMapping(value = "/{ownerId}")
    // @Counted(value = "counted.petclinic.owner")
    public Optional<Owner> findOwner(@PathVariable("ownerId") @Min(1) int ownerId) {
        log.info("Find owner with id {}", ownerId);
        return ownerRepository.findById(ownerId);
    }

    /**
     * Read List of Owners
     */
    @GetMapping
    // @Counted(value = "counted.petclinic.owner")
    public List<Owner> findAll() {
        return ownerRepository.findAll();
    }

    /**
     * Update Owner
     */
    @PutMapping(value = "/{ownerId}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void updateOwner(@PathVariable("ownerId") @Min(1) int ownerId, @Valid @RequestBody OwnerRequest ownerRequest) {
        log.info("Updating owner with id: {} (firstName: {}, lastName: {})", ownerId, ownerRequest.firstName(), ownerRequest.lastName());
        Timer
            .builder("custom.petclinic.owner.update.latency")
            .description("Latency of update owner action")
            .register(meterRegistry)
            .record(() -> {
                final Owner ownerModel = ownerRepository.findById(ownerId).orElseThrow(() -> new ResourceNotFoundException("Owner " + ownerId + " not found"));
                ownerEntityMapper.map(ownerModel, ownerRequest);
                log.info("Saving owner {}", ownerModel);
                ownerRepository.save(ownerModel);
            });
    }
}