package org.springframework.samples.petclinic.customers.web;

import io.micrometer.core.instrument.MeterRegistry;
import io.micrometer.core.instrument.Timer;
import io.micrometer.core.annotation.Timed;
import io.micrometer.core.annotation.Counted;
import jakarta.validation.constraints.Min;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.samples.petclinic.customers.model.*;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@Timed("timed.petclinic.pet")
@Counted(value = "counted.petclinic.pet")
class PetResource {

    private static final Logger log = LoggerFactory.getLogger(PetResource.class);

    private final PetRepository petRepository;
    private final OwnerRepository ownerRepository;
    private final MeterRegistry meterRegistry;

    PetResource(PetRepository petRepository, OwnerRepository ownerRepository, MeterRegistry meterRegistry) {
        this.petRepository = petRepository;
        this.ownerRepository = ownerRepository;
        this.meterRegistry = meterRegistry;
    }

    @GetMapping("/petTypes")
    public List<PetType> getPetTypes() {
        return petRepository.findPetTypes();
    }

    @PostMapping("/owners/{ownerId}/pets")
    @ResponseStatus(HttpStatus.CREATED)
    public Pet processCreationForm(
        @RequestBody PetRequest petRequest,
        @PathVariable("ownerId") @Min(1) int ownerId) {
      
        return Timer
            .builder("custom.petclinic.pet.create.latency")
            .description("Latency of create pet action")
            .register(meterRegistry)
            .record(() -> {
                Owner owner = ownerRepository.findById(ownerId)
                    .orElseThrow(() -> {
                        log.error("Owner with id {} not found", ownerId);
                        return new ResourceNotFoundException("Owner " + ownerId + " not found");
                    });

                final Pet pet = new Pet();
                owner.addPet(pet);
                return save(pet, petRequest);
            });
    }

    @PutMapping("/owners/*/pets/{petId}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void processUpdateForm(@RequestBody PetRequest petRequest) {
        Timer
            .builder("custom.petclinic.pet.update.latency")
            .description("Latency of update pet action")
            .register(meterRegistry)
            .record(() -> {
                int petId = petRequest.id();
                Pet pet = findPetById(petId);
                save(pet, petRequest);
            });

    }

    private Pet save(final Pet pet, final PetRequest petRequest) {

        pet.setName(petRequest.name());
        pet.setBirthDate(petRequest.birthDate());

        petRepository.findPetTypeById(petRequest.typeId())
            .ifPresent(pet::setType);

        log.info("Saving pet {}", pet);
        return petRepository.save(pet);
    }

    @GetMapping("owners/*/pets/{petId}")
    public PetDetails findPet(@PathVariable("petId") int petId) {
        Pet pet = findPetById(petId);
        log.info("Finding pet with id {}", petId);
        return new PetDetails(pet);
    }


    private Pet findPetById(int petId) {
        return petRepository.findById(petId)
            .orElseThrow(() -> {
                log.error("Pet with id {} not found, please try again with another id", petId);
                return new ResourceNotFoundException("Pet " + petId + " not found");
            });
    }

}
